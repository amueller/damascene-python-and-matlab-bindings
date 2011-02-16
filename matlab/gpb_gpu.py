import numpy as np
import os
from scipy.weave import inline,converters

cuda_drv_path="/usr/lib/nvidia-current"
cuda_sdk_path="/usr/local/cuda/C/lib"
cuda_path="/usr/local/cuda/lib"

objects="combine.cu_o rotate.cu_o skeleton.cu_o kmeans.cu_o nonmax.cu_o gradient.cu_o parabola.cu_o spectralPb.cu_o stencilMVM.cu_o localcues.cu_o gpb.cu_o texton.cu_o lanczos.cu_o convert.cu_o Stencil.cpp_o globalPb.cu_o filters.cpp_o intervening.cu_o".split(" ")
objects_dir=[os.path.join("../obj/release/",obj) for obj in objects]
libraries="cuda cutil cudart cublas".split()
library_dirs=[cuda_path,cuda_sdk_path,cuda_drv_path]

def gpb(image,width,height):
    output=np.zeros([width,height],np.float32)
    image=np.array(image).astype(np.uint8)
    code="""
         gpb((unsigned int*)&image(0,0),width,height,&output(0,0));
         """
    inline(code,['image', 'width', 'height','output'], type_converters=converters.blitz, compiler = 'gcc',headers=['"gpb.h"'],include_dirs=['.'],extra_objects=objects_dir,libraries=libraries,library_dirs=library_dirs)


if __name__ == "__main__":
    import Image
    import matplotlib.pyplot as plt
    image=Image.open('test2.ppm')
    #import ipdb
    #ipdb.set_trace();
    data=image.getdata()
    borders=gpb(data,image.size[0],image.size[1]);
    plt.imshow(borders)
    plt.show()

