
#include <mex.h>
#include <gpb.h>

void mexFunction(int nOut, mxArray *pOut[],
		 int nIn, const mxArray *pIn[])
{
  int width, height;
  mxLogical *indataGT, *indataMask, *indataCare;
  unsigned int *out_image;
  unsigned int *in_image;

  if((nIn != 1) || (nOut != 1))
    mexErrMsgTxt("Usage: intersection = overlap_care(GT, mask, care)");
  if (!mxIsUnsignedInt(pIn[0]) || mxGetNumberOfDimensions(pIn[0]) != 2) {
            mexErrMsgTxt("Usage: th argument must be a logical matrix");
        }
  

  width = mxGetM(pIn[0]);
  height = mxGetN(pIn[0]);

  pOut[0]=mxCreateDoubleMatrix(1,1, mxREAL);
  out_image=mxGetPr(pOut[0]);

  in_image (unsigned int*) mxGetData(pIn[0]);
  gpb(in_image,width,height,out_image);  
}
