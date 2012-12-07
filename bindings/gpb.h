/*
 * Written by Andreas Mueller
 * 
 *
 * Compute gPB operator using damascene with cuda
 *
 *
 */

void gpb(const unsigned int* in_image,unsigned int width,unsigned int height, float* border, int* textons, float* orientations, int device_num=0);
