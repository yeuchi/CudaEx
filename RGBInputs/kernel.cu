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
    //printf("\n\nkernel() \n");

    int i = blockDim.x * blockIdx.x + threadIdx.x ; 

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
    kernel<<<maxGridSize,maxThreadsPerBlock>>>(src_lut, des_lut, lut_size, image, width, height, rowSize);   
    
    // host to device memory
    cuda_ret = cudaMemcpy(image, device_image, sizeof(unsigned char)*height*rowSize, cudaMemcpyDeviceToHost);
    if(cuda_ret != cudaSuccess) FATAL("Unable to copy memory to image");

    cudaFree(device_src_lut);
    cudaFree(device_des_lut);
    cudaFree(device_image);
}
