FROM debian:10

# LFS mount point
ENV LFS=/mnt/lfs

# Other LFS parameters
ENV LC_ALL=POSIX
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=/tools/bin:/bin:/usr/bin
ENV MAKEFLAGS="-j 1"

RUN apt-get update &&     \
    apt-get -y upgrade && \
    apt-get install -y    \
    build-essential       \
    bison                 \
    gawk                  \
    python3               \
    texinfo
#XXX: Perl version is 5.28.1, not 5.8.8, which does not meet the requirements.

WORKDIR /bin
RUN rm sh && ln -s bash sh

# Create sources dir as writable and sticky
RUN mkdir -pv     $LFS/sources && \
    chmod -v a+wt $LFS/sources

COPY [ "version-check.sh", "$LFS/sources" ]

WORKDIR $LFS/sources

# Copy and extract toolchain.tar.gz to $LFS/sources
ADD toolchain.tar.gz $LFS/sources
RUN mv $LFS/sources/toolchain/* $LFS/sources/ && \
    rmdir $LFS/sources/toolchain

# create tools directory and symlink
RUN mkdir -pv $LFS/tools && \
    ln    -sv $LFS/tools /

WORKDIR $LFS/sources
