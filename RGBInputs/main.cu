#include <stdio.h>
#include <stdlib.h>
#include "support.h"
//#include <gmac/cuda.h>

void deviceFunction();

int main (int argc, char *argv[])
{
    Timer timer;
    cudaError_t cuda_ret;

    // Initialize host variables ----------------------------------------------

    printf("\nSetting up the problem..."); fflush(stdout);
    startTime(&timer);

    char *RGB_FILE_PATH = "rgb.raw";
    int NUM_PIXELS = 25 * 25 * 25;
    int PIXEL_SIZE = sizeof(unsigned char) * 3;
    unsigned char *rgb_orig;
    unsigned char *rgb_read;

    int RGB_ARRAY_SIZE = sizeof(unsigned char)*NUM_PIXELS*PIXEL_SIZE;
    rgb_orig = (unsigned char*) malloc( RGB_ARRAY_SIZE );
    rgb_read = (unsigned char*) malloc( RGB_ARRAY_SIZE );

    /*
     * Delete prexist rgb.raw file
     */
    removeFile(RGB_FILE_PATH);

    /*
     * Generate a rgb.raw file
     */
    generateRGBImage(rgb_orig);
    
    /*
     * Write rgb.raw file
     */
    writeBinaryFile(rgb_orig, RGB_ARRAY_SIZE, RGB_FILE_PATH);

    /*
     * Read rgb.raw file -- change to look up table file someday ?
     */
    readBinaryFile(rgb_read, RGB_ARRAY_SIZE, RGB_FILE_PATH);

    for(int i=0; i<RGB_ARRAY_SIZE; i++){
        if(rgb_orig[i] != rgb_read[i]) {
            printf("image diff: rgb_orig[%d] rgb_read[%d]\n", i, rgb_orig[i], i, rgb_read[i]);
        }
    }

    //load_file_gmac("rgb.raw", RGB_ARRAY_SIZE);

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

    free(rgb_orig);
    free(rgb_read);
    return 0;
}

// void load_file_gmac(const char* filename, size_t num_bytes) {
//     unsigned char* rgb = NULL;
//     // Allocate shared CPU/GPU pointer via GMAC
//     gmacMalloc((void**)&rgb, num_bytes);

//     // Read file directly into the pointer using standard C host I/O
//     FILE* fp = fopen(filename, "rb");
//     if (fp != NULL) {
//         fread(rgb, 1, num_bytes, fp);
//         fclose(fp);
//     }

//     int i = 0;
//     for (int r=0; r< 256; r++) {
//         for (int g=0; g< 256; g++) {
//             for (int b=0; b< 256; b++) {
//                 printf("[r:%d g:%d b:%d] ", r, g, b);
//                 rgb[i] = r;
//                 i+=1;
//                 rgb[i] = g;
//                 i+=1;
//                 rgb[i] = b;
//                 i+=1;
//             }
//             printf("\n\n g:%d \n", g);
//         }
//         printf("\n\n r:%d \n", r);
//     }

//     // Launch kernel directly—no cudaMemcpy() required
//     //myKernel<<<grid, block>>>(data);
//     //cudaDeviceSynchronize();

//     //gmacFree(data);
// }

