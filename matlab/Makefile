################################################################################
#
# Build script for project
#
################################################################################

# Add source files here
EXECUTABLE	:= gpb
# CUDA source files (compiled with cudacc)

CUFILES := gpb.cu

#LINKCUFILES := kmeans.cu texton.cu convert.cu stencilMVM.cu intervening.cu lanczos.cu localcues.cu gradient.cu rotate.cu parabola.cu spectralPb.cu globalPb.cu combine.cu nonmax.cu skeleton.cu
#LINKCCFILES := Stencil.cpp filters.cpp
################################################################################
# Rules and targets

INCLUDES +=  -I/usr/local/matlab/extern/include

include ../common.mk
#objdir:=../obj/release/
##OBJECTS_LIST:=combine.cu_o  rotate.cu_o  skeleton.cu_o  kmeans.cu_o nonmax.cu_o  gradient.cu_o  parabola.cu_o  spectralPb.cu_o  stencilMVM.cu_o   localcues.cu_o  gpb.cu_o texton.cu_o  lanczos.cu_o   convert.cu_o  Stencil.cpp_o  globalPb.cu_o  textonFilter.cu_o  filters.cpp_o   intervening.cu_o
#OBJECTS_LIST:=combine.cu_o  rotate.cu_o  skeleton.cu_o  kmeans.cu_o nonmax.cu_o  gradient.cu_o  parabola.cu_o  spectralPb.cu_o  stencilMVM.cu_o   localcues.cu_o  gpb.cu_o texton.cu_o  lanczos.cu_o   convert.cu_o  Stencil.cpp_o  globalPb.cu_o  filters.cpp_o   intervening.cu_o

#OBJECTS := $(foreach object, $(OBJECTS_LIST), $(objdir)$(object)) 
gpb.o:
	$(VERBOSE)$(NVCC) -c gpb.cu $(NVCCFLAGS) -m32

#gpb_mex:
	#g++ -O3 -c  -Wall -I/usr/local/matlab/extern/include -DMATLAB_MEX_FILE -pg  -DMX_COMPAT_32   "gpb_mex.c"
gpb_all:
	g++ -O3 -pthread -shared -m32 -Wl,--version-script,/usr/local/matlab/extern/lib/glnx86/mexFunction.map -Wl,--no-undefined -o "gpb_mex.mexglx" gpb_mex.c -lmex -Wl,-rpath-link,/usr/local/matlab/bin/glnx86 -L/usr/local/matlab/bin/glnx86 -lmat -lmx -lm -pg $(LIB) $(INCLUDES) -L../lib/ -ldamascene -lcutil 

