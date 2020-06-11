#!/bin/bash

TOOLCHAIN='./toolchain'

wget -N --input-file=wget-list.ja --continue --directory-prefix=$TOOLCHAIN
wget -N --input-file=wget-list.orig --continue --directory-prefix=$TOOLCHAIN

pushd $TOOLCHAIN
md5sum -c ../md5sums
popd
