# Damascene

GPU gPb image segmentation.

Basic install task list on ubuntu 16.04:

 * Install cuda 8.0
 * Install gcc-5
 * Install Lapack
 * Run cmake and build libdamascene.so
 * Build the python bindings
 * ... start GPU segmenting

### Install CUDA

This assumes you have installed the proprietary nvidia drivers for ubuntu.  (although I think the cuda install process may take care of that).

```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo apt-get update
sudo sudo apt-get install cuda
```

The above download link is for cuda 8.0 on ubuntu 16.04.
Other versions are available here: https://developer.nvidia.com/cuda-downloads


### Install gcc-5
```
sudo apt-get install gcc-5 g++-5
```

Note. Ubuntu 16.04 installs gcc-6 as its default gcc compiler.  Cuda 8.0 requires that a max version of 5 is used.  Later in the process we will set an environment variable to instruct cmake is use gcc-5


### Install Lapack

```
sudo apt-get install liblapack-dev
```

### Run cmake and install libdamascene

Start from the root of the checked out directory.

```
mkdir build
cd build
CC=/usr/bin/gcc-5 cmake .. -DACMLPATH=/usr/local/acml
make -j`cat /proc/cpuinfo | grep MHz | wc -l`
sudo make install
```


### Build and install the python bindings

Start from the root of the checked out directory

```
sudo apt-get install python-pip python-numpy
sudo pip install cython
cd bindings
sudo python setup.py install
```

### ...start GPU segmenting

```
sudo apt-get install python-imaging
sudo apt-get install python-tk
sudo pip install matplotlib
python example.py
```
