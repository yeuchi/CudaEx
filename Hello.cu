#include <iostream>

// CUDA Kernel function to run on the GPU
__global__ void gpuHello() {
    printf("Hello World from GPU thread %d!\n", threadIdx.x);
}

int main() {
    std::cout << "Hello World from CPU!" << std::endl;

    // Launch the kernel on the GPU with 1 block and 5 threads
    gpuHello<<<1, 5>>>();

    // Wait for the GPU to finish before exiting
    cudaDeviceSynchronize();
    
    return 0;
}
