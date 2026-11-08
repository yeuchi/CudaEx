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

    int NUM_PIXELS = 256 * 256 * 256;
    int PIXEL_SIZE = sizeof(unsigned char) * 3;
    unsigned char *rgb;

    int RGB_ARRAY_SIZE = sizeof(unsigned char)*NUM_PIXELS*PIXEL_SIZE;
    rgb = (unsigned char*) malloc( RGB_ARRAY_SIZE );
    generateRGBImage(rgb);
    writeBinaryFile(rgb, RGB_ARRAY_SIZE, "rgb.raw");

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

    deviceFunction();
    
    cuda_ret = cudaDeviceSynchronize();
	if(cuda_ret != cudaSuccess) FATAL("Unable to launch kernel");
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Copy device variables from host ----------------------------------------

    printf("Copying data from device to host..."); fflush(stdout);
    startTime(&timer);


    cudaDeviceSynchronize();
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Free memory ------------------------------------------------------------

    free(rgb);
    return 0;
}

