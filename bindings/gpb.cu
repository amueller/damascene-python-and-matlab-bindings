/*
 * Written by Andreas Mueller
 * Basically copy&paste from damascene.cu
 * Provides C interface to highlevel gPB
 *
 * Compute gPB operator using damascene with cuda
 *
 *
 */

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

#include <iostream>
#define TEXTON64 2
#define TEXTON32 1

void transpose(int width, int height, float* input, float* output) {
  for(int row = 0; row < height; row++) {
    for(int col = 0; col < width; col++) {
      output[col * height + row] = input[row * width + col];
    }
  }                                         
}

void gpb(const unsigned int* in_image,unsigned int width, unsigned int height, float* borders,int* textons, float* orientations, int device_num )
{
	cuInit(0);
	cudaSetDevice(device_num);

	uint* devRgbU;
	/*//copy in_image to device:*/
	uint nPixels = width * height;
	cudaMalloc((void**)&devRgbU, nPixels*sizeof(uint));
	size_t totalMemory, availableMemory;
	cuMemGetInfo(&availableMemory,&totalMemory );
	std::cout<<"Available " << availableMemory << "out of "<< totalMemory<<  " bytes on GPU" <<std::endl;
	cudaMemcpy(devRgbU, in_image, nPixels*sizeof(uint), cudaMemcpyHostToDevice);

	float* devGreyscale;
	rgbUtoGreyF(width, height, devRgbU, &devGreyscale);

	int nTextonChoice = TEXTON64;

	int* devTextons;
	findTextons(width, height, devGreyscale, &devTextons, nTextonChoice);
	//int* hostTextons = (int*)malloc(sizeof(int)*width*height); 
	cudaMemcpy(textons, devTextons, sizeof(int)*width*height, cudaMemcpyDeviceToHost); 


	float* devL;
	float* devA;
	float* devB;
	rgbUtoLab3F(width, height, 2.5, devRgbU, &devL, &devA, &devB);
	normalizeLab(width, height, devL, devA, devB);

	int border = 30;
	float* devLMirrored;
	mirrorImage(width, height, border, devL, &devLMirrored);
	cudaThreadSynchronize();
	cudaFree(devRgbU);
	cudaFree(devGreyscale);
	
	float* devBg;
	float* devCga;
	float* devCgb;
	float* devTg;
	int matrixPitchInFloats;

	localCues(width, height, devL, devA, devB, devTextons, &devBg, &devCga, &devCgb, &devTg, &matrixPitchInFloats, nTextonChoice);
	cudaFree(devTextons);
	cudaFree(devL);
	cudaFree(devA);
	cudaFree(devB);
	float* devMPbO;
	float *devCombinedGradient;
	combine(width, height, matrixPitchInFloats, devBg, devCga, devCgb, devTg, &devMPbO, &devCombinedGradient, nTextonChoice);
	CUDA_SAFE_CALL(cudaFree(devBg));
	CUDA_SAFE_CALL(cudaFree(devCga));
	CUDA_SAFE_CALL(cudaFree(devCgb));
	CUDA_SAFE_CALL(cudaFree(devTg));

	float* devMPb;
	cudaMalloc((void**)&devMPb, sizeof(float) * nPixels);
	nonMaxSuppression(width, height, devMPbO, matrixPitchInFloats, devMPb);
	//int devMatrixPitch = matrixPitchInFloats * sizeof(float);
	int radius = 5;
	//int radius = 10;

	Stencil theStencil(radius, width, height, matrixPitchInFloats);
	int nDimension = theStencil.getStencilArea();
	float* devMatrix;
	intervene(theStencil, devMPb, &devMatrix);
	printf("Intervening contour completed\n");

	float* eigenvalues;
	float* devEigenvectors;
	//int nEigNum = 17;
	int nEigNum = 9;
	float fEigTolerance = 1e-3;
	generalizedEigensolve(theStencil, devMatrix, matrixPitchInFloats, nEigNum, &eigenvalues, &devEigenvectors, fEigTolerance);
	float* devSPb = 0;
	size_t devSPb_pitch = 0;
	CUDA_SAFE_CALL(cudaMallocPitch((void**)&devSPb, &devSPb_pitch, nPixels *  sizeof(float), 8));
	cudaMemset(devSPb, 0, matrixPitchInFloats * sizeof(float) * 8);

	spectralPb(eigenvalues, devEigenvectors, width, height, nEigNum, devSPb, matrixPitchInFloats);
	float* devGPb = 0;
	CUDA_SAFE_CALL(cudaMalloc((void**)&devGPb, sizeof(float) * nPixels));
	float* devGPball = 0;
	CUDA_SAFE_CALL(cudaMalloc((void**)&devGPball, sizeof(float) * matrixPitchInFloats * 8));
	StartCalcGPb(nPixels, matrixPitchInFloats, 8, devCombinedGradient, devSPb, devMPb, devGPball, devGPb);
	float* devGPb_thin = 0;
	CUDA_SAFE_CALL(cudaMalloc((void**)&devGPb_thin, nPixels * sizeof(float) ));
	PostProcess(width, height, width, devGPb, devMPb, devGPb_thin); //note: 3rd param width is the actual pitch of the image
	NormalizeGpbAll(nPixels, 8, matrixPitchInFloats, devGPball);

	cudaThreadSynchronize();
	printf("CUDA Status : %s\n", cudaGetErrorString(cudaGetLastError()));
	/*float* hostGPb = (float*)malloc(sizeof(float)*nPixels);*/
	/*memset(hostGPb, 0, sizeof(float) * nPixels);*/
	std::cout << "nPixels: " << nPixels << std::endl;
	cudaMemcpy(borders, devGPb, sizeof(float)*nPixels, cudaMemcpyDeviceToHost); //TODO: put in again
	/*cudaMemcpy(out_image, devGreyscale, sizeof(float)*nPixels, cudaMemcpyDeviceToHost);*/
	//cutSavePGMf(outputPGMfilename, hostGPb, width, height);
	//writeFile(outputPBfilename, width, height, hostGPb);

	/* thin image */
	//float* hostGPb_thin = (float*)malloc(sizeof(float)*nPixels);
	//memset(hostGPb_thin, 0, sizeof(float) * nPixels);
	/*cudaMemcpy(hostGPb_thin, devGPb_thin, sizeof(float)*nPixels, cudaMemcpyDeviceToHost);*/

	//cutSavePGMf(outputthinPGMfilename, hostGPb_thin, width, height);
	//writeFile(outputthinPBfilename, width, height, hostGPb);
	//free(hostGPb_thin);
	/* end thin image */

  float* hostGPbAll = (float*)malloc(sizeof(float) * matrixPitchInFloats * 8);
  cudaMemcpy(hostGPbAll, devGPball, sizeof(float) * matrixPitchInFloats * 8, cudaMemcpyDeviceToHost);
  //int oriMap[] = {0, 1, 2, 3, 4, 5, 6, 7};
  //int oriMap[] = {4, 5, 6, 7, 0, 1, 2, 3};
  int oriMap[] = {3, 2, 1, 0, 7, 6, 5, 4};
  for(int i = 0; i < 8; i++) {
    transpose(width, height, hostGPbAll + matrixPitchInFloats * oriMap[i], orientations + width * height * i);
  }
  //int dim[3];
  //dim[0] = 8; 
  //dim[1] = width;
  //dim[2] = height;
  //writeArray(outputgpbAllfilename, 3, dim, hostGPbAllConcat);
  
  
  //for(int orientation = 0; orientation < 8; orientation++) {
	//sprintf(nIndicator, "_%i_Pb.pgm", orientation);
	//cutSavePGMf("orientation.pgm", hostGPbAll + matrixPitchInFloats * orientation, width, height);
  //}
  
	/*free(hostGPb);*/
	free(hostGPbAll);
	//free(hostGPbAllConcat);


	CUDA_SAFE_CALL(cudaFree(devEigenvectors));
	CUDA_SAFE_CALL(cudaFree(devCombinedGradient));
	CUDA_SAFE_CALL(cudaFree(devSPb));
	CUDA_SAFE_CALL(cudaFree(devGPb));
	CUDA_SAFE_CALL(cudaFree(devGPb_thin));
	CUDA_SAFE_CALL(cudaFree(devGPball));
	cudaThreadExit();
}

int main(){

	return 0;
}

