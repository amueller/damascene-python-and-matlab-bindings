import numpy as np
cimport numpy as np

np.import_array()

cdef extern from "gpb.h":
    cdef void gpb(unsigned int* in_image,unsigned int width, unsigned int
             height, float* borders, int* textons, float* orientations, int device_num)


def damascene(image, int device_num=0):
    if (image.shape[2] != 3):
        raise ValueError("Image needs to have 3 channels.")
    cdef int height = image.shape[0]
    cdef int width = image.shape[1]
    cdef np.ndarray[np.float32_t, ndim=2] borders = np.zeros([height, width], np.float32)
    cdef np.ndarray[np.float32_t, ndim=3] orientations = np.zeros([8, width, height], np.float32)
    cdef np.ndarray[np.int32_t, ndim=2] textons = np.zeros([height, width], np.int32)
    cdef np.ndarray[np.uint8_t, ndim=3] padded_image = np.zeros([height, width, 4], np.uint8)
    padded_image[:, :, :3] = image.astype(np.uint8)
    gpb(<unsigned int*>padded_image.data, width ,height, <float*>borders.data,
        <int*>textons.data, <float*>orientations.data, device_num);
    return borders, textons, orientations
