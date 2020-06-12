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

#{{{ Build GCC(1)
echo "Building gcc..."
tar -xf gcc-*.tar.xz -C /tmp/ && \
  mv /tmp/gcc-* /tmp/gcc && \
  pushd /tmp/gcc && \
  tar -xf $LFS/sources/mpfr-*.tar.xz && \
  mv -v mpfr-* mpfr && \
  tar -xf $LFS/sources/gmp-*.tar.xz && \
  mv -v gmp-* gmp && \
  tar -xf $LFS/sources/mpc-*.tar.gz && \
  mv -v mpc-* mpc && \
  for file in gcc/config/{linux,i386/linux{,64}}.h; do \
      cp -uv $file{,.orig}; \
      sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' -e 's@/usr@/tools@g' $file.orig > $file; \
      echo -e "#undef STANDARD_STARTFILE_PREFIX_1 \n#undef STANDARD_STARTFILE_PREFIX_2 \n#define STANDARD_STARTFILE_PREFIX_1 \"/tools/lib/\" \n#define STANDARD_STARTFILE_PREFIX_2 \"\"" >> $file; \
      touch $file.orig; \
    done \
  && case $(uname -m) in \
     x86_64) \
       sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 \
       ;; \
    esac \
  && mkdir -v build \
  && cd build \
  && ../configure                                   \
    --target=$LFS_TGT                              \
    --prefix=/tools                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++                       \
  && make \
  && make install \
  && popd \
  && rm -rf /tmp/gcc
#}}}

#{{{ Build Linux API Headers
echo "Building Linux API Headers..."
tar -xf linux-*.tar.xz -C /tmp/ \
  && mv /tmp/linux-* /tmp/linux \
  && pushd /tmp/linux \
  && make mrproper \
  && make headers \
  && cp -rv usr/include/* /tools/include \
  && popd \
  && rm -rf /tmp/linux
#}}}

#{{{ Build Glibc
tar -xf glibc-*.tar.xz -C /tmp/ \
  && mv /tmp/glibc-* /tmp/glibc \
  && pushd /tmp/glibc \
  && mkdir -v build \
  && cd build \
  && ../configure                       \
    --prefix=/tools                    \
    --host=$LFS_TGT                    \
    --build=$(../scripts/config.guess) \
    --enable-kernel=3.2                \
    --with-headers=/tools/include      \
  && make \
  && make install \
  && popd \
  && rm -rf /tmp/glibc

# perform a sanity check that basic functions (compiling and linking)
# are working as expected
echo 'int main(){}' > dummy.c \
  && $LFS_TGT-gcc dummy.c \
  && readelf -l a.out | grep ': /tools' \
  && rm -v dummy.c a.out
#}}}

#{{{ Build libstdc++
tar -xf gcc-*.tar.xz -C /tmp/ \
  && mv /tmp/gcc-* /tmp/gcc \
  && pushd /tmp/gcc \
  && mkdir -v build \
  && cd build \
  && ../libstdc++-v3/configure        \
     --host=$LFS_TGT                 \
     --prefix=/tools                 \
     --disable-multilib              \
     --disable-nls                   \
     --disable-libstdcxx-threads     \
     --disable-libstdcxx-pch         \
     --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/9.2.0 \
  && make \
  && make install \
  && popd \
  && rm -rf /tmp/gcc
#}}}
