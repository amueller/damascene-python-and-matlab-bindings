// vim: ts=4 syntax=cpp comments=

#include <stdlib.h>
#include <stdio.h>
#include <cuda.h>
#include <cutil.h>
#include <fcntl.h>
#include <float.h>
#include <unistd.h>
#include "texton.h"
#include "convert.h"
#include "intervening.h"
#include "lanczos.h"
#include "stencilMVM.h"

#include "localcues.h"
#include "combine.h"
#include "nonmax.h"
#include "spectralPb.h"
#include "globalPb.h"
#include "skeleton.h"

#define __TIMER_SPECFIC

#define TEXTON64 2
#define TEXTON32 1

float* loadArray(char* filename, uint& width, uint& height) {
  FILE* fp;
  fp = fopen(filename, "r");
  int dim;
  fread(&dim, sizeof(int), 1, fp);
  assert(dim == 2);
  fread(&width, sizeof(int), 1, fp);
  fread(&height, sizeof(int), 1, fp);
  float* buffer = (float*)malloc(sizeof(float) * width * height);
  int counter = 0;
  for(int col = 0; col < width; col++) {
    for(int row = 0; row < height; row++) {
      float element;
      fread(&element, sizeof(float), 1, fp);
      counter++;
      buffer[row * width + col] = element;
    }
  }
 /*  for(int row = 0; row < height; row++) { */
/*     for(int col = 0; col < width; col++) { */
/*       printf("%f ", buffer[row*width + col]); */
/*     } */
/*     printf("\n"); */
/*   } */
  return buffer;
}

void writeTextImage(const char* filename, uint width, uint height, float* image) {
  FILE* fp = fopen(filename, "w");
  for(int row = 0; row < height; row++) {
    for(int col = 0; col < width; col++) {
      fprintf(fp, "%f ", image[row * width + col]);
    }
    fprintf(fp, "\n");
  }
  fclose(fp);
}

void writeFile(char* file, int width, int height, int* input)
{
    int fd;
    float* pb = (float*)malloc(sizeof(float)*width*height);
    for(int i = 0; i < width * height; i++) {
      pb[i] = (float)input[i];
    }
    fd = open(file, O_CREAT|O_WRONLY, 0666);
    write(fd, &width, sizeof(int));
    write(fd, &height, sizeof(int));
    write(fd, pb, width*height*sizeof(float));
    close(fd);
}

void writeFile(char* file, int width, int height, float* pb)
{
    int fd;

    fd = open(file, O_CREAT|O_WRONLY, 0666);
    write(fd, &width, sizeof(int));
    write(fd, &height, sizeof(int));
    write(fd, pb, width*height*sizeof(float));
    close(fd);
}

void writeGradients(char* file, int width, int height, int pitchInFloats, int norients, int scales, float* pb)
{
    int fd;

    fd = open(file, O_CREAT|O_WRONLY, 0666);
    write(fd, &width, sizeof(int));
    write(fd, &height, sizeof(int));
    write(fd, &norients, sizeof(int));
    write(fd, &scales, sizeof(int));
    for(int scale = 0; scale < scales; scale++) {
      for(int orient = 0; orient < norients; orient++) {
        float* currentPointer = &pb[pitchInFloats * orient + pitchInFloats * scale * norients];
        write(fd, currentPointer, width*height*sizeof(float));
      }
    }
    close(fd);
}

void writeArray(char* file, int ndim, int* dim, float* input) {
  int fd;
  fd = open(file, O_CREAT|O_WRONLY|O_TRUNC, 0666);
  int size = 1;
  for(int i = 0; i < ndim; i++) {
    size *= dim[i];
  }
  write(fd, &ndim, sizeof(int));
  write(fd, dim, sizeof(int) * ndim);
  write(fd, input, sizeof(float) * size);
  close(fd);
}

