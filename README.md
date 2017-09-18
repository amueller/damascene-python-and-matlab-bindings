# Damascene

GPU gPb image segmentation.

Basic install task list on ubuntu 16.04:

 * Install cuda 8.0
 * Install gcc-5
 * Install ACML
 * Run cmake and build libdamascene.so
 * Build the python bindings
 * ... start GPU segmenting

### Install CUDA

This assumes you have installed the proprietary nvidia drivers for ubuntu.  (although I think the cuda intall process may take care of that)

```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo apt-get update
sudo sudo apt-get install cuda
```

### Install gcc-5
```
sudo apt-get install gcc-5 g++-5
```

### Install ACML

Download from here http://developer.amd.com/tools-and-sdks/archive/acml-downloads-resources/#download

The installer is somewhat interactive.  Select ```/usr/local/acml``` as your install directory

```
tar -zxf acml-5-3-1-gfortran-64bit.tgz
sudo ./install-acml-5-3-1-gfortran-64bit.sh
sudo echo '/usr/local/acml/gfortran64/lib' > /etc/ld.so.conf.d/acml.conf
sudo ldconfig
```

### Run cmake and install libdamascene

Start from the root of the checked out directory

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
