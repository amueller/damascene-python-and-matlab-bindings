#ifndef __MY_FAKE_CUTIL__
#define __MY_FAKE_CUTIL__


#define CUDA_SAFE_CALL(X) {X; checkCudaError(#X);} 

#include <stdexcept>

inline void checkCudaError(const char *msg)
{
    cudaError_t err = cudaGetLastError();
    if( cudaSuccess != err) 
    {
        throw std::runtime_error(std::string(msg) + cudaGetErrorString(err) );
    }                         
}
#endif
