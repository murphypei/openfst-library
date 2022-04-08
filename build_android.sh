#!/usr/bin/bash

set -e
set -x

version=1.6.5

# Download openfst archive
if [[ ! -f openfst-$version.tar.gz ]]; then
    wget -T 10 -t 1 http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-$version.tar.gz -O openfst-$version.tar.gz
fi
tar -zxvf openfst-$version.tar.gz

# Create android NDK standalone toolchain
toolchain=/tmp/android-toolchain
arch=arm64
api_level=23
stl=c++_shared
rm -rf $toolchain
if [[ ! -d $ANDROID_NDK ]]; then
    echo "ANDROID_NDK path doesn't exist!"
    exit
fi
cd $ANDROID_NDK/build/tools
python make_standalone_toolchain.py --arch $arch --api $api_level --stl=$stl --install-dir $toolchain
cd -
export PATH=$toolchain/bin:$PATH

# Build and install
install_dir=$(pwd)/android-$arch-$api_level
if [[ ! -d $install_dir ]]; then
    mkdir -p $install_dir
fi

cd openfst-$version
CXX=clang++ ./configure \
    --prefix=$install_dir \
    --disable-bin \
    --enable-static \
    --enable-shared \
    --host=aarch64-linux-android \
    CXXFLAGS="-std=c++11 -fPIC" \
    LIBS="-ldl"

make install -j6
cd ..

# Clean
rm -rf $toolchain
rm -rf openfst-$version
