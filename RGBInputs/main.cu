#include <stdio.h>
#include <stdlib.h>
#include "support.h"

void deviceFunction();

int main (int argc, char *argv[])
{
    Timer timer;
    cudaError_t cuda_ret;

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
     * !! Change path to point at DES_LUT_FILE_PATH !!
     */
    readBinaryFile(des_lut, LUT_ARRAY_SIZE, SRC_LUT_FILE_PATH);



    /*
     * Do Image processing with above LUTs (or profiles info or BPN weights)
     */
    char *SRC_IMG_FILE_PATH = "src_img.raw";
    char *DES_IMG_FILE_PATH = "des_img.raw";
    int IMAGE_WIDTH = 1000;
    int IMAGE_HEIGHT = 1000;
    int IMAGE_SIZE = IMAGE_WIDTH * IMAGE_HEIGHT * PIXEL_SIZE;
    unsigned char *image = (unsigned char*) malloc( IMAGE_SIZE );

   // readBinaryFile(image, IMAGE_SIZE, SRC_IMG_FILE_PATH);

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

   // deviceLookUpTable(src_lut, des_lut, RGB_ARRAY_SIZE, image, IMAGE_SIZE);
    
    cuda_ret = cudaDeviceSynchronize();
	if(cuda_ret != cudaSuccess) FATAL("Unable to launch kernel");
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Copy device variables from host ----------------------------------------

    printf("Copying data from device to host..."); fflush(stdout);
    startTime(&timer);

    cudaDeviceSynchronize();
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Free memory ------------------------------------------------------------

    free(src_lut);
    free(des_lut);
    free(image);
    return 0;
}

