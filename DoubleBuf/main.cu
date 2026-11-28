#include <stdio.h>
#include <stdlib.h>
#include "support.h"

/*
 * https://www.coddykit.com/courses/learn_cuda/the-double-buffering-pipeline-12275510
 */

#define CHUNK_ELEMENTS (1024 * 1024) // 1M floats per chunk (~4 MB)
#define CHUNK_BYTES (CHUNK_ELEMENTS * sizeof(float))


__global__ void processChunk(const float* in, float* out, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        out[idx] = in[idx] * 2.0f + 1.0f;
    }
}
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


    int image_size = 256*256*256*3;
    unsigned char *image = (unsigned char*)malloc(image_size*sizeof(unsigned char));
    generateRGBImage(image);
    writeBinaryFile(image, image_size, "input.bin");


    FILE *fin = fopen("input.bin", "rb");
    FILE *fout = fopen("output.bin", "wb");
    if (!fin || !fout) {
        perror("File open failed");
        return 1;
    }

    // 1. Allocate double buffers (Pinned Host + Device) and Streams
    float *h_in[2], *h_out[2];
    float *d_in[2], *d_out[2];
    cudaStream_t streams[2];
    size_t items_read[2] = {0, 0};

    for (int i = 0; i < 2; i++) {
        cudaMallocHost(&h_in[i], CHUNK_BYTES);
        cudaMallocHost(&h_out[i], CHUNK_BYTES);
        cudaMalloc(&d_in[i], CHUNK_BYTES);
        cudaMalloc(&d_out[i], CHUNK_BYTES);
        cudaStreamCreate(&streams[i]);
    }

    int blockSize = 256;
    int iter = 0;

    // 2. Main Double-Buffering Loop
    while (1) {
        printf("while loop iter:%d\n", iter);
        int cur = iter % 2;

        // Wait for previous work on this buffer slot to finish before reusing it
        if (iter >= 2) {
            cudaStreamSynchronize(streams[cur]);
            // Write the completed output from 2 iterations ago to disk
            int bytes_wrote = fwrite(h_out[cur], sizeof(float), items_read[cur], fout);
            printf("cur: %d bytes_wrote: %d \n", cur, bytes_wrote);
        }

        // Read next chunk from disk into pinned host memory
        items_read[cur] = fread(h_in[cur], sizeof(float), CHUNK_ELEMENTS, fin);
        printf("items_read[%d]: %d \n", cur, items_read[cur]);

        if (items_read[cur] == 0) {
            break; // End of file reached
            printf("End of file reached \n");
        }

        size_t current_bytes = items_read[cur] * sizeof(float);
        int gridSize = (items_read[cur] + blockSize - 1) / blockSize;

        // Enqueue async H2D copy, kernel execution, and D2H copy into the stream
        cudaMemcpyAsync(d_in[cur], h_in[cur], current_bytes, cudaMemcpyHostToDevice, streams[cur]);
        processChunk<<<gridSize, blockSize, 0, streams[cur]>>>(d_in[cur], d_out[cur], items_read[cur]);
        cudaMemcpyAsync(h_out[cur], d_out[cur], current_bytes, cudaMemcpyDeviceToHost, streams[cur]);

        iter++;
    }

    // 3. Drain/Flush the remaining in-flight buffer(s)
    // If iter == 1, only slot 0 was used. If iter >= 2, both slots may have pending writes.
    int pending = (iter == 1) ? 1 : 2;
    for (int i = 0; i < pending; i++) {
        int slot = (iter - pending + i) % 2;
        if (items_read[slot] > 0) {
            cudaStreamSynchronize(streams[slot]);
            fwrite(h_out[slot], sizeof(float), items_read[slot], fout);
        }
    }

    // Free memory ------------------------------------------------------------

    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    for (int i = 0; i < 2; i++) {
        cudaStreamDestroy(streams[i]);
        cudaFreeHost(h_in[i]);
        cudaFreeHost(h_out[i]);
        cudaFree(d_in[i]);
        cudaFree(d_out[i]);
    }
    fclose(fin);
    fclose(fout);
    return 0;
}

