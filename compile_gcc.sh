#!/bin/sh

#Adapted from: https://kristerw.blogspot.com/2017/04/building-gcc-with-support-for-nvidia.html

GCC_VERSION=12.2.0
WORK_DIR=
INSTALL_DIR=
NUM_THREADS=
CUDA=

if [ -z "$CUDA" ] || [ -z "$NUM_THREADS" ] || [ -z "$INSTALL_DIR" ] || [ -z "$WORK_DIR" ]; then
	echo "Some variables are not specified"
	exit 1
fi

GCC_SRC=$WORK_DIR/gcc-$GCC_VERSION
GCC_ARCHIVE_NAME=gcc-$GCC_VERSION.tar.gz
GCC_ARCHIVE_LINK=http://mirror.koddos.net/gcc/releases/gcc-$GCC_VERSION/$GCC_ARCHIVE_NAME

NEWLIB_VERSION=4.2.0.20211231
NEWLIB_SRC=$WORK_DIR/newlib-$NEWLIB_VERSION
NEWLIB_ARCHIVE_NAME=newlib-$NEWLIB_VERSION.tar.gz
NEWLIB_ARCHIVE_LINK=http://sourceware.org/pub/newlib/$NEWLIB_ARCHIVE_NAME

NVPTX_TOOLS_LINK=https://github.com/MentorEmbedded/nvptx-tools
NVPTX_TOOLS_SRC=$WORK_DIR/nvptx-tools

if [ ! -d $CUDA ]; then
	echo "Could not find cuda directory: $CUDA"
	exit
fi

cd "$WORK_DIR" || exit

[ -e $GCC_ARCHIVE_NAME ] || wget $GCC_ARCHIVE_LINK
tar xvf $GCC_ARCHIVE_NAME

[ -e $NEWLIB_ARCHIVE_NAME ] || wget $NEWLIB_ARCHIVE_LINK
tar xvf $NEWLIB_ARCHIVE_NAME

[ -d master ] || git clone $NVPTX_TOOLS_LINK

# Build assembler and linking tools
(
cd "$NVPTX_TOOLS_SRC" || exit
./configure \
    --with-cuda-driver-include=$CUDA/include \
    --with-cuda-driver-lib=$CUDA/lib64 \
    --prefix="$INSTALL_DIR"
make -j$NUM_THREADS || exit
make install || exit
)

# Set up the GCC source tree
(
cd "$GCC_SRC" || exit
ln -s "$NEWLIB_SRC"/newlib newlib
)
TARGET=$("$GCC_SRC"/config.guess)

# Build nvptx GCC
(
mkdir build-nvptx-gcc
cd build-nvptx-gcc || exit
"$GCC_SRC"/configure \
    --target=nvptx-none --with-build-time-tools="$INSTALL_DIR"/nvptx-none/bin \
    --enable-as-accelerator-for="$TARGET" \
    --disable-sjlj-exceptions \
    --enable-newlib-io-long-long \
    --enable-languages="c,c++,fortran,lto" \
    --prefix="$INSTALL_DIR"
make -j$NUM_THREADS || exit
make install || exit
)

# Build host GCC
(
mkdir build-host-gcc
cd  build-host-gcc || exit
"$GCC_SRC"/configure \
    --enable-offload-targets=nvptx-none \
    --with-cuda-driver-include=$CUDA/include \
    --with-cuda-driver-lib=$CUDA/lib64/stubs/ \
    --disable-bootstrap \
    --disable-multilib \
    --enable-languages="c,c++,fortran,lto" \
    --prefix="$INSTALL_DIR"
make -j$NUM_THREADS || exit
make install || exit
)

