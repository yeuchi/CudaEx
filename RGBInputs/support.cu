#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#include "support.h"

void generateRGBImage(unsigned char *rgb) {
    int i = 0;
    for (int r=0; r< 256; r++) {
        for (int g=0; g< 256; g++) {
            for (int b=0; b< 256; b++) {
                printf("[r:%d g:%d b:%d] ", r, g, b);
                rgb[i] = r;
                i+=1;
                rgb[i] = g;
                i+=1;
                rgb[i] = b;
                i+=1;
            }
            printf("\n\n g:%d \n", g);
        }
        printf("\n\n r:%d \n", r);
    }
}

void writeTextFile(unsigned char *rgb, int size, char* file_name)
{
    FILE* output = fopen(file_name, "w");
    for (unsigned i = 0; i < size; i++) {
        fprintf(output, "%f, ", rgb[i]);
    }
}

void writeBinaryFile(unsigned char *rgb, int size, char* file_name)
{
    FILE* output = fopen(file_name, "wb");
    size_t elements_written = fwrite(rgb, sizeof(float), size, output);
    printf("elements writte: %zu\n",elements_written);
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

