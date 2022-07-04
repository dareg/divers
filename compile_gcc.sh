#!/bin/sh

#Adapted from: https://kristerw.blogspot.com/2017/04/building-gcc-with-support-for-nvidia.html

num_threads=12
work_dir=$HOME/test-gcc-9/
install_dir=$HOME/softs/gcc/9.3/
cuda=/usr/lib/cuda/

cd $work_dir
gcc_src=$work_dir/gcc-9.3.0

#https://sourceware.org/newlib/
newlib_src=$work_dir/newlib-3.3.0
#git clone https://github.com/MentorEmbedded/nvptx-tools
nvptx_tools_src=$work_dir/nvptx-tools-master

# Build assembler and linking tools
cd $nvptx_tools_src
./configure \
    --with-cuda-driver-include=$cuda/include \
    --with-cuda-driver-lib=$cuda/lib64 \
    --prefix=$install_dir
make -j$num_threads
make install
cd ..

# Set up the GCC source tree
cd $gcc_src
ln -s $newlib_src/newlib newlib
cd ..
target=$($gcc_src/config.guess)

# Build nvptx GCC
mkdir build-nvptx-gcc
cd build-nvptx-gcc
$gcc_src/configure \
    --target=nvptx-none --with-build-time-tools=$install_dir/nvptx-none/bin \
    --enable-as-accelerator-for=$target \
    --disable-sjlj-exceptions \
    --enable-newlib-io-long-long \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j$num_threads
make install
cd ..

# Build host GCC
mkdir build-host-gcc
cd  build-host-gcc
$gcc_src/configure \
    --enable-offload-targets=nvptx-none \
    --with-cuda-driver-include=$cuda/include \
    --with-cuda-driver-lib=$cuda/lib64 \
    --disable-bootstrap \
    --disable-multilib \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j$num_threads
make install
cd ..

