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
     * Do Image processing with above LUTs (or profiles info or BPN weights)
     */
    // char *SRC_IMG_FILE_PATH = "src_img.raw";
    // int IMAGE_WIDTH = 1000;
    // int IMAGE_HEIGHT = 1000;
    // int IMAGE_SIZE = IMAGE_WIDTH * IMAGE_HEIGHT * PIXEL_SIZE;
    // unsigned char *image = (unsigned char*) malloc( IMAGE_SIZE );
    // readBinaryFile(image, IMAGE_SIZE, SRC_IMG_FILE_PATH);

    int width, height, rowSize;
    unsigned char *image = readBmp(&width, &height, &rowSize, argv[1]);

    stopTime(&timer); 
    printf("%f s\n", elapsedTime(timer));
    printf("Image dimensions: %u x %u\n", NUM_PIXELS);

    // Allocate device variables ----------------------------------------------
    printf("Allocate device variables..."); fflush(stdout);
    startTime(&timer);

    cudaDeviceSynchronize();
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Copy host variables to device ------------------------------------------

    printf("Copying data from host to device..."); fflush(stdout);
    startTime(&timer);

    cudaDeviceSynchronize();
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Launch kernel using standard sgemm interface ---------------------------
    printf("Launching kernel..."); fflush(stdout);
    startTime(&timer);

    deviceLookUpTable(src_lut, 
        des_lut, 
        LUT_ARRAY_SIZE, 
        image, width, 
        height, 
        rowSize,
        maxThreadsPerBlock,
        maxThreadsPerMultiProcessor,
        maxGridSize);
    
    cuda_ret = cudaDeviceSynchronize();
	if(cuda_ret != cudaSuccess) FATAL("Unable to launch kernel");
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Copy device variables from host ----------------------------------------

    printf("Copying data from device to host...\n"); fflush(stdout);
    startTime(&timer);

    cudaDeviceSynchronize();

    writeBmp("processed.bmp", image, width, height, rowSize);

    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Measure CPU Compute ----------------------------------------------------
    printf("CPU Compute..."); fflush(stdout);
    startTime(&timer);


    void hostLookUpTable(unsigned char* src_lut, unsigned char* des_lut, int lut_size, unsigned char* image,
                            int width, int height, int rowSize, int maxThreadsPerBlock, int maxThreadsPerMultiProcessor, int maxGridSize);

    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Free memory ------------------------------------------------------------

    free(src_lut);
    free(des_lut);
    free(image);
    return 0;
}

