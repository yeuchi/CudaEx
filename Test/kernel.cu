#include <stdio.h>
#include <stdlib.h>
#include "support.h"

/*
 * GPU Kernel function
 * - do octree lookup ?
 * - do BPN ?
 * - do Matrix or other math on pixel 
 */
__global__ void kernel(unsigned char* src_lut,              // [in] source look up table
                        unsigned char* des_lut,             // [in] destination look up table
                        int lut_size,                       // [in] look up table size
                        unsigned char* image,               // [in/out] image pixels
                        int width,                          // [in] image width
                        int height,                         // [in] image height
                        int rowSize)                        // [in] 1 row of image size
{
    int i = blockDim.x * blockIdx.x + threadIdx.x * 3 ; 

    /*
     * Don't need src_lut if it is uniform 
     */
    if(i < (height * rowSize - 2)) {

        if(image[i] != 0 && image[i+1] != 0 && image[i+2] != 0) {
            unsigned char r = (unsigned char)(((float)image[i]/(float)255));
            unsigned char g = (unsigned char)(((float)image[i+1]/(float)255));
            unsigned char b = (unsigned char)(((float)image[i+2]/(float)255));

            int j = (r * 25 * 25 + g * 25 + b) * 3;
            j = (j>=lut_size-3)? lut_size-3:j;

            printf("j:%d\n",j);
            unsigned char rr = des_lut[j];
            unsigned char gg = des_lut[j+1];
            unsigned char bb = des_lut[j+2];

            image[i] = (unsigned char)((float)rr*(float)255/(float)25);
            image[i+1] = (unsigned char)((float)gg*(float)255/(float)25);
            image[i+2] = (unsigned char)((float)bb*(float)255/(float)25);
            //printf("threadIdx.x: %d, blockIdx.x: %d, blockDim.x: %d i: %d\n", threadIdx.x, blockIdx.x, blockDim.x, i);
        }
    }
}

/*
 * Do device GPU execution
 */
void deviceLookUpTable( unsigned char* src_lut,              // [in] source look up table
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
    printf("\n\ndeviceLookUpTable() \n");

    unsigned char *device_src_lut;
    unsigned char *device_des_lut;
    unsigned char *device_image;
    cudaError_t cuda_ret;

    // allocate
    cuda_ret = cudaMalloc((void**) &device_src_lut, sizeof(unsigned char)*lut_size);
    if(cuda_ret != cudaSuccess) FATAL("Unable to allocate device_src_lut");
    
    cuda_ret = cudaMalloc((void**) &device_des_lut, sizeof(unsigned char)*lut_size);
    if(cuda_ret != cudaSuccess) FATAL("Unable to allocate device_des_lut");
    
    cuda_ret = cudaMalloc((void**) &device_image, sizeof(unsigned char)*rowSize*height);
    if(cuda_ret != cudaSuccess) FATAL("Unable to allocate device_image");

    // host to device memory
    cuda_ret = cudaMemcpy(device_src_lut, src_lut, sizeof(unsigned char)*lut_size, cudaMemcpyHostToDevice);
    if(cuda_ret != cudaSuccess) FATAL("Unable to copy memory to device_src_lut");

    cuda_ret = cudaMemcpy(device_des_lut, des_lut, sizeof(unsigned char)*lut_size, cudaMemcpyHostToDevice);
    if(cuda_ret != cudaSuccess) FATAL("Unable to copy memory to device_des_lut");

    cuda_ret = cudaMemcpy(device_image, image, sizeof(unsigned char)*height*rowSize, cudaMemcpyHostToDevice);
    if(cuda_ret != cudaSuccess) FATAL("Unable to copy memory to device_image");

    // INSERT CODE HERE
    int imageSize = rowSize * height * 3;
    int GridSizeNeeded = imageSize / maxThreadsPerBlock + 1;
    /*
     * !Need to handle image bigger than maxGridSize !
     */
     printf("GridSizeNeeded:%d maxThreadsPerBlock:%d \n", GridSizeNeeded, maxThreadsPerBlock);
    kernel<<<GridSizeNeeded,maxThreadsPerBlock>>>(device_src_lut, device_des_lut, lut_size, device_image, width, height, rowSize);   
    
    // host to device memory
    cuda_ret = cudaMemcpy(image, device_image, sizeof(unsigned char)*height*rowSize, cudaMemcpyDeviceToHost);
    if(cuda_ret != cudaSuccess) FATAL("Unable to copy memory to image");

    cudaFree(device_src_lut);
    cudaFree(device_des_lut);
    cudaFree(device_image);
}
