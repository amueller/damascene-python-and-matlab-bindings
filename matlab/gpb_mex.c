
#include <mex.h>
#include "gpb.h"

void mexFunction(int nOut, mxArray *pOut[],
		 int nIn, const mxArray *pIn[])
{
  mwSize width, height;
  unsigned int *out_image;
  unsigned int *in_image;
  mwSize dims[3];

  if((nIn != 1) || (nOut != 1))
    mexErrMsgTxt("Usage: border = gpb(image)");
if (!mxIsClass(pIn[0],"uint8") || mxGetNumberOfDimensions(pIn[0]) != 3) {
		mexErrMsgTxt("Usage: th argument must be a unsigned int matrix");
	}
  
  width = mxGetM(pIn[0]);
  height = mxGetN(pIn[0]);
  dims[0]=width; dims[1]=height; dims[2]=3; //for rgb
  pOut[0]=mxCreateNumericArray(3,dims,mxUINT8_CLASS,mxREAL);
  out_image=(unsigned int*) mxGetPr(pOut[0]);

  in_image = (unsigned int*) mxGetData(pIn[0]);
  gpb(in_image,width,height,out_image);  
}
