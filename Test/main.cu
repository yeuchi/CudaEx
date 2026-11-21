#include <stdio.h>
#include <stdlib.h>
#include "support.h"

void deviceLookUpTable(unsigned char* src_lut,      // [in] source look up table
                        unsigned char* des_lut,     // [in] destination look up table
                        int lut_size,               // [in] look up table size
                        unsigned char* image,       // [in/out] image pixels
                        int width,                  // [in] image width
                        int height,                 // [in] image height
                        int rowSize,                        // [in] 1 row of image size
                        int maxThreadsPerBlock,             // [in] max threads
                        int maxThreadsPerMultiProcessor,    // [in] max threads / process
                        int maxGridSize);                    // [in] max grid size

int main (int argc, char *argv[])
{
    Timer timer;
    cudaError_t cuda_ret;

    // Read GPU capability ----------------------------------------------

    int deviceId = 0; // Check the first GPU
    cudaDeviceProp prop;
    
    // Fetch device properties
    cudaError_t status = cudaGetDeviceProperties(&prop, deviceId);

    int maxThreadsPerBlock = prop.maxThreadsPerBlock;
    int maxThreadsPerMultiProcessor = prop.maxThreadsPerMultiProcessor;
    int maxGridSize = prop.maxGridSize[0];

    // Initialize host variables ----------------------------------------------

    printf("\nSetting up the problem..."); fflush(stdout);
    startTime(&timer);

    // Look up tables
    char *SRC_LUT_FILE_PATH = "src_lut.raw";
    char *DES_LUT_FILE_PATH = "des_lut.raw";
    int NUM_PIXELS = 25 * 25 * 25;
    int NUM_COLORS = 3;
    int PIXEL_SIZE = sizeof(unsigned char) * NUM_COLORS;
    int LUT_ARRAY_SIZE = sizeof(unsigned char)*NUM_PIXELS*PIXEL_SIZE;
    unsigned char *src_lut = (unsigned char*) malloc( LUT_ARRAY_SIZE );
    unsigned char *des_lut = (unsigned char*) malloc( LUT_ARRAY_SIZE );

    /*
     * Delete prexist rgb.raw file
     */
    removeFile(SRC_LUT_FILE_PATH);

    /*
     * Generate a rgb.raw file
     */
    generateRGBImage(src_lut);
    
    /*
     * Write rgb.raw file
     */
    writeBinaryFile(src_lut, LUT_ARRAY_SIZE, SRC_LUT_FILE_PATH);

    /*
     * Read rgb.raw file -- change to look up table file someday ?
     */
    readBinaryFile(des_lut, LUT_ARRAY_SIZE, DES_LUT_FILE_PATH);

    /*
     * Write lut as a bitmap
     */
    int width, height, rowSize;

    width = NUM_PIXELS;
    height = 1;
    rowSize = ((width * 3 + 3) / 4) * 4;
    writeBmp("lut.bmp", src_lut, width, height, rowSize);

    int imageWidth, imageHeight, imageRowSize; 
    unsigned char *image = readBmp(&imageWidth, &imageHeight, &imageRowSize, "lut.bmp");

    printf("width: %d imageWidth: %d \n", width, imageWidth);
    printf("height: %d imageHeight: %d \n", height, imageHeight);
    printf("rowSize: %d imageRowSize: %d \n", rowSize, imageRowSize);

    compareArrays(src_lut, image, LUT_ARRAY_SIZE);

    stopTime(&timer); 
    printf("%f s\n", elapsedTime(timer));

    // Free memory ------------------------------------------------------------

    free(src_lut);
    free(des_lut);
    free(image);
    return 0;
}

