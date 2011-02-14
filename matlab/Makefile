################################################################################
#
# Build script for project
#
################################################################################

# Add source files here
#EXECUTABLE	:= texton
# CUDA source files (compiled with cudacc)

CUFILES := gpb.cu

################################################################################
# Rules and targets

INCLUDES +=  -I/usr/local/matlab/extern/include

include ../common.mk
gpb:
	$(VERBOSE)$(NVCC) -c gpb.cu $(NVCCFLAGS)
