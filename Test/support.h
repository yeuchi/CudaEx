#ifndef __FILEH__
#define __FILEH__

#include <sys/time.h>
#include <stdint.h>

typedef struct {
    struct timeval startTime;
    struct timeval endTime;
} Timer;

#ifdef __cplusplus
extern "C" {
#endif

void createRGBImage(unsigned char *rgb);
void createGrayScale(unsigned char *image);
void createRedScale(unsigned char *image);
void createGreenScale(unsigned char *image);
void createBlueScale(unsigned char *image);

void writeTextFile(unsigned char *rgb, int size, char* file_name);
void writeBinaryFile(unsigned char *rgb, int size, char* file_name);
void readBinaryFile(unsigned char *rgb, int size, char* file_name);
void removeFile(char* file_name);
unsigned char* readBmp(int *width, int *height, int *rowSize, char* file_name);
void writeBmp(  char* file_name, unsigned char* data, int widith, int height, int rowStride);
void compareArrays( unsigned char *rgb_orig, unsigned char *rgb_read, int size);

void startTime(Timer* timer);
void stopTime(Timer* timer);
float elapsedTime(Timer timer);
void hostLookUpTable(   unsigned char* src_lut,              // [in] source look up table
                        unsigned char* des_lut,             // [in] destination look up table
                        int lut_size,                       // [in] look up table size
                        unsigned char* image,               // [in/out] image pixels
                        int width,                          // [in] image width
                        int height,                         // [in] image height
                        int rowSize,                        // [in] 1 row of image size
                        int maxThreadsPerBlock,             // [in] max threads
                        int maxThreadsPerMultiProcessor,    // [in] max threads / process
                        int maxGridSize);

typedef struct {
    //uint16_t bfType;      // Magic identifier: "BM" (0x4D42)
    uint32_t bfSize;      // Total file size in bytes
    uint16_t bfReserved1; // Reserved (0)
    uint16_t bfReserved2; // Reserved (0)
    uint32_t bfOffBits;   // Offset to pixel data (54 bytes)
} BMPFileHeader;

typedef struct {
    uint32_t biSize;          // Header size (40 bytes)
    int32_t  biWidth;         // Image width in pixels
    int32_t  biHeight;        // Image height (negative = top-down)
    uint16_t biPlanes;        // Color planes (must be 1)
    uint16_t biBitCount;      // Bits per pixel (24 for RGB)
    uint32_t biCompression;   // Compression (0 = BI_RGB uncompressed)
    uint32_t biSizeImage;     // Image data size in bytes
    int32_t  biXPelsPerMeter; // Horizontal resolution (0)
    int32_t  biYPelsPerMeter; // Vertical resolution (0)
    uint32_t biClrUsed;       // Colors in palette (0)
    uint32_t biClrImportant;  // Important colors (0)
} BMPInfoHeader;

#ifdef __cplusplus
}
#endif

#define FATAL(msg, ...) \
    do {\
        fprintf(stderr, "[%s:%d] %s\n", __FILE__, __LINE__, msg, ##__VA_ARGS__);\
        exit(-1);\
    } while(0)

#if __BYTE_ORDER != __LITTLE_ENDIAN
# error "File I/O is not implemented for this system: wrong endianness."
#endif

#endif
