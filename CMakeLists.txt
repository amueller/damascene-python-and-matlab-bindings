cmake_minimum_required( VERSION 2.6 FATAL_ERROR )

PROJECT(damascene Fortran CXX C)

FIND_PACKAGE(CUDA REQUIRED)

SET(CMAKE_MODULE_PATH  ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/CMakeModules)

CUDA_INCLUDE_DIRECTORIES( ${CUDA_SDK_ROOT_DIR}/common/inc ${CMAKE_CURRENT_SOURCE_DIR})
INCLUDE_DIRECTORIES(      ${CUDA_SDK_ROOT_DIR}/common/inc ${CUDA_INCLUDE_DIRS}       )
INCLUDE_DIRECTORIES(      ${CMAKE_SOURCE_DIR}/include                                )
CUDA_INCLUDE_DIRECTORIES( ${CMAKE_SOURCE_DIR}/include                                )

SET(USERACMLPATH "${ACMLPATH}")
FILE(TO_CMAKE_PATH ${USERACMLPATH} USERACMLPATH)

IF(NOT EXISTS "${USERACMLPATH}/gfortran64/include/acml.h")
    MESSAGE(SEND_ERROR "Can't find acml.h in ${USERACMLPATH}/gfortran64/include/")
ELSE()
    MESSAGE(STATUS "Using ACML from path: " ${USERACMLPATH})
ENDIF()


INCLUDE_DIRECTORIES(${ACMLPATH}gfortran64/include)
LINK_Directories(${ACMLPATH}gfortran64/lib)


SET(CUDA_ARCHITECTURE "-arch=sm_20" CACHE STRING "The CUDA architecture to compile for, i.e. -arch=sm_20")
SET(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};${CUDA_ARCHITECTURE}")


SET(DAMASCENE_SRC
    bindings/gpb.cu
    #combine/combine.64.cu
    combine/combine.cu
    convert/convert.cu
    damascene/damascene.cu
    gPb/globalPb.cu
    intervening/intervening.cu
    #localcues/gradient.64.cu
    localcues/gradient.cu
    #localcues/localcues.64.cu
    localcues/localcues.cu
    localcues/parabola.cu
    #localcues/parabola_kernel.cu
    #localcues/rotate.64.cu
    localcues/rotate.cu
    nonmax/nonmax.cu
    noReorthog/lanczos.cu
    #noReorthog/spectralPb.cu
    #noReorthog/spectralPb_kernel.cu
    postprocess/skeleton.cu
    sPb/spectralPb.cu
    stencilMatrixMultiply/stencilMVM.cu
    #textons/kmeans.64.cu
    textons/kmeans.cu
    #textons/kmeans_noatomics.cu
    #textons/texton.64.cu
    textons/texton.cu
    #textons/textonFilter.cu
    #stencilMatrixMultiply/load_smatrix.cpp
    stencilMatrixMultiply/Stencil.cpp
    textons/filters.cpp
    )


CUDA_ADD_LIBRARY(damascene SHARED ${DAMASCENE_SRC})
CUDA_ADD_CUBLAS_TO_TARGET(damascene)
TARGET_LINK_LIBRARIES(damascene ${CUDA_LIBRARIES} cuda acml)

if (UNIX)
    install(TARGETS damascene DESTINATION lib/${OUTPUT_NAME})
    install(CODE "execute_process(COMMAND ldconfig)")
endif()