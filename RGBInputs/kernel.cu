#include <stdio.h>

/*
 * GPU Kernel function
 * - do octree lookup ?
 * - do BPN ?
 * - do Matrix or other math on pixel 
 */
__global__ void kernel() {
    printf("\n\nkernel() \n");

   
}

/*
 * Do device GPU execution
 */
void deviceLookUpTable(unsigned char* src_lut,      // [in] source look up table
                        unsigned char* des_lut,     // [in] destination look up table
                        int lut_size,               // [in] look up table size
                        unsigned char* image,       // [in/out] image pixels
                        int width,                  // [in] image width
                        int height,                 // [in] image height
                        int rowSize) {              // [in] 1 row of image size

    printf("\n\ndeviceLookUpTable() \n");
    // type cast unsigned char(0-25) to float (0-1F)

    // INSERT CODE HERE
    kernel<<<1,1>>>();

}
