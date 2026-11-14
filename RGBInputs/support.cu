#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "support.h"

/*
 * Generate a RGB image 25x25x25
 */
void generateRGBImage(unsigned char *rgb)   // [in] rgb data
{
    int i = 0;
    for (int r=0; r< 25; r++) {
        for (int g=0; g< 25; g++) {
            for (int b=0; b< 25; b++) {
                if(b % 10 == 0){
                printf("[r:%d g:%d b:%d] ", r, g, b);
                rgb[i] = r;
                i+=1;
                rgb[i] = g;
                i+=1;
                rgb[i] = b;
                i+=1;
                }
            }
            printf("\n\n g:%d \n", g);
        }
        printf("\n\n r:%d \n", r);
    }
}

/*
 * Delete a file
 */
void removeFile(char* file_name)            // [in] filename and path
{
    remove(file_name);
}

/*
 * Write a Text file
 */
void writeTextFile(unsigned char *rgb,      // [in] rgb data
                    int size,               // [in] rgb data array size in bytes
                    char* file_name)        // [in] filename and path
{
    FILE* file = fopen(file_name, "w");
    for (unsigned i = 0; i < size; i++) {
        fprintf(file, "%f, ", rgb[i]);
    }
    fclose(file);
}

/*
 * Write a binary file
 */
void writeBinaryFile(unsigned char *rgb,    // [in] rgb data
                    int size,               // [in] rgb data array size in bytes
                    char* file_name)        // [in] filename and path
{
    FILE* file = fopen(file_name, "wb");
    size_t elements_written = fwrite(rgb, sizeof(unsigned char), size, file);
    printf("elements written: %zu\n",elements_written);
    fclose(file);
}

/*
 * Read a binary file
 */
void readBinaryFile(unsigned char *buffer,  // [in] empty allocated array
                    int size, char*         // [in] array size in bytes
                    file_name)              // [in] filename and path
{
    FILE *file = fopen(file_name, "rb");
    if (file == NULL) {
        printf("Error opening file\n");
        return;
    }

    // 2. Find the file size
    fseek(file, 0, SEEK_END);      // Move pointer to the end of the file
    long fileSize = ftell(file);   // Get current pointer position (size in bytes)
    fseek(file, 0, SEEK_SET);      // Reset pointer back to the beginning

    printf("fileSize: %ld expected:%d \n", fileSize, size);
    if(fileSize > size) {
        printf("File too large\n");
        return;
    }

    size_t bytesRead = fread(buffer, sizeof(unsigned char), fileSize, file);
    printf("bytesRead: %zu fileSize:%ld\n", bytesRead, fileSize);

    if (bytesRead != fileSize) {
        printf("Wrong size read \n");
    }

    // 6. Clean up
    fclose(file);
}

/*
 * Compare 2 image arrays for differences
 */
void compareArrays(unsigned char *rgb_orig, unsigned char *rgb_read, int size) {
        for(int i=0; i<RGB_ARRAY_SIZE; i++){
        if(rgb_orig[i] != rgb_read[i]) {
            printf("image diff: rgb_orig[%d] rgb_read[%d]\n", i, rgb_orig[i], i, rgb_read[i]);
        }
    }    
}

void startTime(Timer* timer) {
    gettimeofday(&(timer->startTime), NULL);
}

void stopTime(Timer* timer) {
    gettimeofday(&(timer->endTime), NULL);
}

float elapsedTime(Timer timer) {
    return ((float) ((timer.endTime.tv_sec - timer.startTime.tv_sec) \
                + (timer.endTime.tv_usec - timer.startTime.tv_usec)/1.0e6));
}

