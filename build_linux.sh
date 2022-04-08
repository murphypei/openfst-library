#!/usr/bin/bash

set -e
set -x

version=1.6.5

# Download openfst archive
if [[ ! -f openfst-$version.tar.gz ]]; then
    wget -T 10 -t 1 http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-$version.tar.gz -O openfst-$version.tar.gz
fi
tar -zxvf openfst-$version.tar.gz

# Build and install
install_dir=$(pwd)/linux
if [[ ! -d $install_dir ]]; then
    mkdir -p $install_dir
fi

cd openfst-$version
./configure \
    --disable-bin \
    --prefix=$install_dir \
    --enable-static \
    --enable-shared \
    CXXFLAGS="-std=c++11 -fPIC" \
    LIBS="-ldl"

make install -j6
cd ..

# Clean
rm -rf openfst-$version
