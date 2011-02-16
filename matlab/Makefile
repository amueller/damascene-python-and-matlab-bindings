################################################################################
#
# Build script for project
#
################################################################################

# Add source files here
EXECUTABLE	:= gpb
# CUDA source files (compiled with cudacc)

CUFILES := gpb.cu

LINKCUFILES := kmeans.cu texton.cu convert.cu stencilMVM.cu intervening.cu lanczos.cu localcues.cu gradient.cu rotate.cu parabola.cu spectralPb.cu globalPb.cu combine.cu nonmax.cu skeleton.cu
LINKCCFILES := Stencil.cpp filters.cpp
################################################################################
# Rules and targets
MATLABPATH=/home/VI/staff/amueller/bin/matlab
INCLUDES +=  -I$(MATLABPATH)/extern/include

include ../common.mk
objdir:=../obj/release/
OBJECTS_LIST:=combine.cu_o  rotate.cu_o  skeleton.cu_o  kmeans.cu_o nonmax.cu_o  gradient.cu_o  parabola.cu_o  spectralPb.cu_o  stencilMVM.cu_o   localcues.cu_o  gpb.cu_o texton.cu_o  lanczos.cu_o   convert.cu_o  Stencil.cpp_o  globalPb.cu_o  filters.cpp_o   intervening.cu_o

OBJECTS := $(foreach object, $(OBJECTS_LIST), $(objdir)$(object)) 

gpb_mex:
	g++ -O3 -pthread -shared -m32 -Wl,--version-script,$(MATLABPATH)/extern/lib/glnx86/mexFunction.map -Wl,--no-undefined -o "gpb_mex.mexglx" $(OBJECTS) gpb_mex.c -lmex -Wl,-rpath-link,$(MATLABPATH)/bin/glnx86 -L$(MATLABPATH)/bin/glnx86 -lmat -lmx -lm -pg $(LIB) $(INCLUDES) -lcutil_i386

