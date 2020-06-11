#!/bin/bash

wget -N --input-file=wget-list.ja --continue --directory-prefix=./toolchain
wget -N --input-file=wget-list.orig --continue --directory-prefix=./toolchain
