#!/bin/bash
set -eu

#{{{ Build binutils(1)
echo "Building binutils..."

tar -xf binutils-*.tar.xz -C /tmp/ && \
    mv /tmp/binutils-* /tmp/binutils && \
    pushd /tmp/binutils && \
    mkdir -v build && \
    cd build && \
    ../configure               \
    --prefix=/tools            \
    --with-sysroot=$LFS        \
    --with-lib-path=/tools/lib \
    --target=$LFS_TGT          \
    --disable-nls              \
    --disable-werror        && \
    make && \
    mkdir -pv /tools/lib && \
    ln -sv lib /tools/lib64 && \
    make install && \
    popd && \
    rm -rf /tmp/binutils
#}}}
