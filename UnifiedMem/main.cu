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
    unsigned char *src_lut;
    unsigned char *des_lut;

    cudaMallocManaged(&src_lut, LUT_ARRAY_SIZE*sizeof(unsigned char));
    cudaMallocManaged(&des_lut, LUT_ARRAY_SIZE*sizeof(unsigned char));

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
    readBinaryFile(des_lut, LUT_ARRAY_SIZE, SRC_LUT_FILE_PATH);

    /*
     * Do Image processing with above LUTs (or profiles info or BPN weights)
     */
    int width, height, rowSize;
    unsigned char *image;
    readBmpInfo(&width, &height, &rowSize, argv[1]);

    int imageSize = height*rowSize;
    cudaMallocManaged(&image, imageSize);
    readBmp(image, imageSize, argv[1]);

    stopTime(&timer); 
    printf("%f s\n", elapsedTime(timer));
    printf("Image dimensions: %u x %u\n", NUM_PIXELS);

    // Invoke device function ---------------------------
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

    cudaFree(src_lut);
    cudaFree(des_lut);
    cudaFree(image);
    return 0;
}

