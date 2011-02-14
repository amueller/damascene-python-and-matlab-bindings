
#include <mex.h>
#include "gpb.h"

void mexFunction(int nOut, mxArray *pOut[],
		 int nIn, const mxArray *pIn[])
{
  int width, height;
  unsigned int *out_image;
  unsigned int *in_image;

  if((nIn != 1) || (nOut != 1))
    mexErrMsgTxt("Usage: border = gpb(image)");
if (!mxIsClass(pIn[0],"uint8") || mxGetNumberOfDimensions(pIn[0]) != 2) {
		mexErrMsgTxt("Usage: th argument must be a unsigned int matrix");
	}
  
  width = mxGetM(pIn[0]);
  height = mxGetN(pIn[0]);

  pOut[0]=mxCreateNumericMatrix(width,height,mxUINT8_CLASS,mxREAL);
  out_image=(unsigned int*) mxGetPr(pOut[0]);

  in_image = (unsigned int*) mxGetData(pIn[0]);
  gpb(in_image,width,height,out_image);  
}
