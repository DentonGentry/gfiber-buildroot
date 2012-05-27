#!/bin/sh

set -x
set -e

BUILD_DIR=../local-toolchain
TOOLCHAIN_DIR=../toolchains/bruno

rm -rf ${BUILD_DIR} && mkdir -p ${BUILD_DIR}
make bruno_toolchain_defconfig
cp .config ${BUILD_DIR}

set +e
make O=${BUILD_DIR} -j -l12
make O=${BUILD_DIR}
set -e

repo start new-toolchain toolchains/bruno
rm -rf ${TOOLCHAIN_DIR}/*

rsync -vaP ${BUILD_DIR}/host/usr/bin/mipsel* ${TOOLCHAIN_DIR}/bin/
rsync -vaP ${BUILD_DIR}/host/usr/bin/ld* ${TOOLCHAIN_DIR}/bin/
rsync -vaP ${BUILD_DIR}/host/usr/libexec ${TOOLCHAIN_DIR}
rsync -vaP ${BUILD_DIR}/host/usr/lib/{gcc,ldscripts,libiberty.a} ${TOOLCHAIN_DIR}/lib/
rsync -vaP ${BUILD_DIR}/host/usr/mipsel-unknown-linux-uclibc ${TOOLCHAIN_DIR}
rsync -vaP ${BUILD_DIR}/host/usr/share/{gcc*,locale} ${TOOLCHAIN_DIR}/share/
rsync -vaP ${BUILD_DIR}/host/usr/share/man/man7 ${TOOLCHAIN_DIR}/share/man
rsync -vaP ${BUILD_DIR}/host/usr/share/man/man1/mips* ${TOOLCHAIN_DIR}/share/man/man1
ln -sf mipsel-unknown-linux-uclibc ${TOOLCHAIN_DIR}/mipsel-linux

cd $TOOLCHAIN_DIR && git add -A .
