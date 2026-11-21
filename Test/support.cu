#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "support.h"



/*
 * Generate a RGB image 25x25x25
 */
void createRGBImage(unsigned char *rgb)   // [in] rgb data
{
    printf("\n\ncreateRGBImage() \n");

    int i = 0;
    for (int r=0; r< 25; r++) {
        for (int g=0; g< 25; g++) {
            for (int b=0; b< 25; b++) {
                //printf("[r:%d g:%d b:%d] ", r, g, b);
                rgb[i++] = r;
                rgb[i++] = g;
                rgb[i++] = b;
            }
           // printf("\n\n g:%d \n", g);
        }
        //printf("\n\n r:%d \n", r);
    }
}

/*
 * create Grayscale image
 */
void createGrayScale(unsigned char *image) {
    printf("\n\createGrayScale() \n");
    int j = 0;
    for (int i=0; i< 256; i++) {
        image[j++] = i;
        image[j++] = i;
        image[j++] = i;
    }
}

/*
 * create Red image
 */
void createRedScale(unsigned char *image) {
    printf("\n\createRedScale() \n");
    int j = 0;
    for (int i=0; i< 256; i++) {
        image[j++] = i;
        image[j++] = 0;
        image[j++] = 0;
    }
}

/*
 * create Green image
 */
void createGreenScale(unsigned char *image) {
    printf("\n\createGreenScale() \n");
    int j = 0;
    for (int i=0; i< 256; i++) {
        image[j++] = 0;
        image[j++] = i;
        image[j++] = 0;
    }
}

/*
 * create Blue image
 */
void createBlueScale(unsigned char *image) {
    printf("\n\createBlueScale() \n");
    int j = 0;
    for (int i=0; i< 256; i++) {
        image[j++] = 0;
        image[j++] = 0;
        image[j++] = i;
    }
}

/*
 * Delete a file
 */
void removeFile(char* file_name)            // [in] filename and path
{
    printf("\n\nremoveFile() %s\n", file_name);
    remove(file_name);
}

/*
 * Write a Text file
 */
void writeTextFile(unsigned char *rgb,      // [in] rgb data
                    int size,               // [in] rgb data array size in bytes
                    char* file_name)        // [in] filename and path
{
    printf("\n\nwriteTextFile() %s\n", file_name);

    FILE* file = fopen(file_name, "w");
    for (unsigned i = 0; i < size; i++) {
        fprintf(file, "%f, ", rgb[i]);
    }
    fclose(file);
}

/*
 * Write a binary file
 * https://lmcnulty.me/words/bmp-output/
 */
void writeBinaryFile(unsigned char *rgb,    // [in] rgb data
                    int size,               // [in] rgb data array size in bytes
                    char* file_name)        // [in] filename and path
{
    printf("\n\nwriteBinaryFile() %s\n", file_name);

    FILE* file = fopen(file_name, "wb");
    size_t elements_written = fwrite(rgb, sizeof(unsigned char), size, file);
    printf("elements written: %zu\n",elements_written);
    fclose(file);
}

/*
 * Read a binary file
 */
void readBinaryFile(unsigned char *buffer,  // [in] empty allocated array
                    int size,               // [in] array size in bytes
                    char* file_name)        // [in] filename and path
{
    printf("\n\nreadBinaryFile() %s\n", file_name);

    FILE *file = fopen(file_name, "rb");
    if (file == NULL) {
        printf("Error opening file\n");
        return;
    }

    // 2. Find the file size
    fseek(file, 0, SEEK_END);      // Move pointer to the end of the file
    long fileSize = ftell(file);   // Get current pointer position (size in bytes)
    fseek(file, 0, SEEK_SET);      // Reset pointer back to the beginning

    printf("fileSize: %ld expected:%d \n", fileSize, size);
    if(fileSize > size) {
        printf("File too large\n");
        return;
    }

    size_t bytesRead = fread(buffer, sizeof(unsigned char), fileSize, file);
    printf("bytesRead: %zu fileSize:%ld\n", bytesRead, fileSize);

    if (bytesRead != fileSize) {
        printf("Wrong size read \n");
    }

    // 6. Clean up
    fclose(file);
}

/*
 * Read a bitmap file
 */
unsigned char* readBmp( int *width,             // [out] image width in pixels
                        int *height,            // [out] image height in pixels
                        int *rowSize,           // [out] image row byte count
                        char* file_name)        // [in] filename and path
{
    printf("\n\nreadBmp() %s\n", file_name);
    
    FILE* f = fopen(file_name, "rb");
    if (!f) {
        printf("Error: Could not open file %s\n", file_name);
        return NULL;
    }

    unsigned char header[54];
    if (fread(header, sizeof(unsigned char), 54, f) != 54) {
        printf("Error: Invalid BMP header\n");
        fclose(f);
        return NULL;
    }

    // Verify 'BM' signature
    if (header[0] != 'B' || header[1] != 'M') {
        printf("Error: Not a valid BMP file\n");
        fclose(f);
        return NULL;
    }

    // Extract image dimensions and data offset from header
    uint32_t fileSize = *(uint32_t*)&header[2];
    uint32_t dataOffset = *(uint32_t*)&header[10];
    *width              = *(int32_t*)&header[18];
    *height             = *(int32_t*)&header[22];
    uint16_t bpp        = *(uint16_t*)&header[28];

    if (bpp != 24) {
        printf("Error: Only 24-bit uncompressed BMPs are supported\n");
        fclose(f);
        return NULL;
    }

    // BMP rows are padded to the nearest 4-byte boundary
    *rowSize = ((*width * 3 + 3) / 4) * 4;
    size_t dataSize = (*rowSize) * abs(*height);

    unsigned char* data = (unsigned char*)malloc(dataSize);
    fseek(f, dataOffset, SEEK_SET);
    fread(data, sizeof(unsigned char), dataSize, f);
    fclose(f);

    printf("width: %d height: %d bpp: %d rowSize: %d dataSize: %zu\n\n", *width, *height, (int)bpp, *rowSize, dataSize);
    return data;
}

/*
 * Write Bitmap file 
 */
void writeBmp(  char* file_name,        // [in] destination file name path
                unsigned char* data,    // [in] image pixels
                int width,              // [in] image width
                int height,             // [in] image height
                int rowStride) {        // [in] row size in bytes
    printf("\n\nwriteBMP() %s\n", file_name);

    int padding = rowStride - (width * 3);
    uint32_t dataSize = rowStride * height;

    BMPFileHeader fileHeader = {0};
    //fileHeader.bfType = 0x4D42;
    fileHeader.bfSize = sizeof(BMPFileHeader) + sizeof(BMPInfoHeader) + dataSize+2;
    fileHeader.bfOffBits = sizeof(BMPFileHeader) + sizeof(BMPInfoHeader) + 2;

    BMPInfoHeader infoHeader = {0};
    infoHeader.biSize = sizeof(BMPInfoHeader);
    infoHeader.biWidth = width;
    infoHeader.biHeight = height; // Negative height writes top-to-bottom
    infoHeader.biPlanes = 1;
    infoHeader.biBitCount = 24;
    infoHeader.biCompression = 0;
    infoHeader.biSizeImage = dataSize;
    infoHeader.biXPelsPerMeter = 2835;
    infoHeader.biYPelsPerMeter = 2835;
    infoHeader.biClrUsed - 0;
    infoHeader.biClrImportant = 0;

    FILE* fp = fopen(file_name, "wb");
    if (!fp) {
        perror("Failed to open file");
        return;
    }
    unsigned char BM[2] = {'B', 'M'};
    fwrite(BM, 2, 1, fp);
    fwrite(&fileHeader, sizeof(fileHeader), 1, fp);
    fwrite(&infoHeader, sizeof(infoHeader), 1, fp);
    fwrite(data, 1, dataSize, fp);
    if(padding > 0) {
        uint8_t pad_bytes[3] = {0, 0, 0};
        fwrite(pad_bytes, 1, padding, fp);
    }
    fclose(fp);
    printf("image written \n");
}

/*
 * Do host CPU execution
 */
void hostLookUpTable(   unsigned char* src_lut,              // [in] source look up table
                        unsigned char* des_lut,             // [in] destination look up table
                        int lut_size,                       // [in] look up table size
                        unsigned char* image,               // [in/out] image pixels
                        int width,                          // [in] image width
                        int height,                         // [in] image height
                        int rowSize,                        // [in] 1 row of image size
                        int maxThreadsPerBlock,             // [in] max threads
                        int maxThreadsPerMultiProcessor,    // [in] max threads / process
                        int maxGridSize)                    // [in] max grid size
{
    for(int y=0; y<height; y++) {
        int yy = rowSize * y;
        for (int x=0; x<width; x++) {
            int i = x * 3 + yy;
            unsigned char r = image[i];
            unsigned char g = image[i+1];
            unsigned char b = image[i+2];
            //Concept, 
            unsigned char interp_r = src_lut[r*3];
            unsigned char interp_g = src_lut[g*3+1];
            unsigned char interp_b = src_lut[b*3+2];

            image[i] = des_lut[interp_r*3];
            image[i+1] = des_lut[interp_g*3+1];
            image[i+2] = des_lut[interp_b*3+2];
            /*
             * TODO Look up table and computation
             */

        }
    }
}

/*
 * Compare 2 image arrays for differences
 */
void compareArrays( unsigned char *rgb_orig,    // [in] 1st array 
                    unsigned char *rgb_read,    // [in] 2nd array
                    int size) {                 // [in] array size
    printf("\n\ncompareArrays() \n");

    for(int i=0; i<size; i++){
        if(rgb_orig[i] != rgb_read[i]) {
            printf("image diff: rgb_orig[%d] rgb_read[%d]\n", i, rgb_orig[i], i, rgb_read[i]);
            return;
        }
    }
    printf("arrays matched \n");    
}

void startTime(Timer* timer) {
    gettimeofday(&(timer->startTime), NULL);
}

void stopTime(Timer* timer) {
    gettimeofday(&(timer->endTime), NULL);
}

float elapsedTime(Timer timer) {
    return ((float) ((timer.endTime.tv_sec - timer.startTime.tv_sec) \
                + (timer.endTime.tv_usec - timer.startTime.tv_usec)/1.0e6));
}

