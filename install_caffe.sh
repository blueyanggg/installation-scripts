# the original scripts to https://github.com/BVLC/caffe/wiki/Caffe-installing-script-for-ubuntu-16.04---support-Cuda-8

# Below is the script to automatic install caffe, cuda and all it's dependencies. Tested work on AWS g2.2xlarge instance
# If you do not want to use CuDNN, run with USE_CUDNN=0
# first install docker follow
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
# then install nvidia-docker follow the offcial guide
CUDNN_TAR_FILE="cudnn-8.0-linux-x64-v5.0-ga-tgz"
if [ "$USE_CUDNN" != "0" ]; then
  if [ ! -f "/tmp/${CUDNN_TAR_FILE}" ] ; then
      curl -o /tmp/${CUDNN_TAR_FILE} https://developer.nvidia.com/rdp/assets/cudnn-8.0-linux-x64-v5.0-ga-tgz${CUDNN_TAR_FILE}
  fi
fi

# Add Nvidia's cuda repository
wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb
sudo dpkg -i cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64.deb

sudo apt-get update
sudo apt-get install cuda
# Note that we do upgrade and not dist-upgrade so that we don't install
# new kernels; this script will install the nvidia driver in the *currently
# running* kernel.
sudo apt-get upgrade -y
sudo apt-get install -y opencl-headers build-essential protobuf-compiler \
    libprotoc-dev libboost-all-dev libleveldb-dev hdf5-tools libhdf5-serial-dev \
    libopencv-core-dev  libopencv-highgui-dev libsnappy-dev \
    libatlas-base-dev cmake libstdc++6-4.8-dbg libgoogle-glog0v5 libgoogle-glog-dev \
    libgflags-dev liblmdb-dev git python-pip gfortran libopencv-dev
sudo apt-get clean

# Nvidia's driver depends on the drm module, but that's not included in the default
# 'virtual' ubuntu that's on the cloud (as it usually has no graphics).  It's 
# available in the linux-image-extra-virtual package (and linux-image-generic supposedly),
# but just installing those directly will install the drm module for the NEWEST available
# kernel, not the one we're currently running.  Hence, we need to specify the version
# manually.  This command will probably need to be re-run every time you upgrade the
# kernel and reboot.
#sudo apt-get install -y linux-headers-virtual linux-source linux-image-extra-virtual
sudo apt-get install -y linux-image-extra-`uname -r` linux-headers-`uname -r` linux-image-`uname -r`

sudo apt-get install -y cuda-8.0
sudo apt-get clean

# Optionally, download your own cudnn; requires registration.  
if [ "$USE_CUDNN" != "0" ]; then
  tar -xvf /tmp/${CUDNN_TAR_FILE} -C /tmp
  sudo cp -P /tmp/cuda/lib64/* /usr/local/cuda/lib64
  sudo cp /tmp/cuda/include/* /usr/local/cuda/include
fi
# Need to put cuda on the linker path.  This may not be the best way, but it works.
sudo sh -c "sudo echo '/usr/local/cuda/lib64' > /etc/ld.so.conf.d/cuda_hack.conf"
sudo ldconfig /usr/local/cuda/lib64


# Get caffe, and install python requirements
git clone https://github.com/BVLC/caffe.git
cd caffe
cd python
for req in $(cat requirements.txt); do sudo pip install $req; done

# Prepare Makefile.config so that it can build on aws
cd ../
cp Makefile.config.example Makefile.config
if [ "$USE_CUDNN" != "0" ]; then
  sed -i '/^# USE_CUDNN := 1/s/^# //' Makefile.config
fi
sed -i '/^# WITH_PYTHON_LAYER := 1/s/^# //' Makefile.config
sed -i 's/\/usr\/local\/cuda/\/usr\/local\/cuda-8.0/g' Makefile.config
sed -i 's/\/usr\/local\/include/\/usr\/local\/include \/usr\/include\/hdf5\/serial/g' Makefile.config
sed -i '/^PYTHON_INCLUDE/a    /usr/local/lib/python2.7/dist-packages/numpy/core/include/ \\' Makefile.config

sudo ln -s /usr/lib/x86_64-linux-gnu/libhdf5_serial.so.10.1.0 /usr/lib/x86_64-linux-gnu/libhdf5.so
sudo ln -s /usr/lib/x86_64-linux-gnu/libhdf5_serial_hl.so.10.0.2 /usr/lib/x86_64-linux-gnu/libhdf5_hl.so

# And finally build!
make -j 8 all py

make -j 8 test
make runtest

echo "export PYTHONPATH=/opt/cat-dogs/repo/caffe/python:$PYTHONPATH" >> ~/.bashrc
