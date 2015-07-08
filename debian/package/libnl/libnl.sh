#!/bin/bash
#
# 1. Download package and unpack package
# 2. Copy debian/directory to it
# 3. Run dpkg-buildpackage --arch=<ARCH> -rfakeroot

set -e

export DEBFULLNAME="Amain (DebWrt.net)"
export LC_ALL=C
VERBOSE=1

[ "1" == $VERBOSE ] && set -x

PACKAGE=libnl
VERSION=1.1
RELEASE=1
PACKAGE_SOURCE=${PACKAGE}-${VERSION}.tar.gz
DOWNLOAD_URL=http://www.infradead.org/~tgr/libnl/files/${PACKAGE_SOURCE}
DEP=

BASE_DIR=/usr/src
BUILD_BASE_DIR=${BASE_DIR}/${PACKAGE}
BUILD_DIR=${BUILD_BASE_DIR}/${PACKAGE}-${VERSION}
DOWNLOAD_DIR=${BASE_DIR}/dl

if ! ( dpkg --get-selections | grep debwrt-kernel-headers )
then
   echo "debwrt-kernel-headers package not installed"
   exit 1
fi

mkdir -p $DOWNLOAD_DIR
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
if [ ! -s ${DOWNLOAD_DIR}/${PACKAGE_SOURCE} ]; then rm -f ${DOWNLOAD_DIR}/${PACKAGE_SOURCE}; wget -O ${DOWNLOAD_DIR}/${PACKAGE_SOURCE} $DOWNLOAD_URL; fi
tar xzf ${DOWNLOAD_DIR}/${PACKAGE_SOURCE} -C ${BUILD_DIR} --strip 1
cp -rav debian ${BUILD_DIR} | head -n 6  # copy all, but only show first lines
cd ${BUILD_DIR}
dpkg-buildpackage -a${ARCH} -rfakeroot

# build and install deb cross packages
cd ${BUILD_BASE_DIR}
find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb"  | grep -v _all.deb | xargs -r -t sudo dpkg-cross -a ${ARCH} -b || true
find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb"  | grep    _all.deb | xargs -r -t sudo dpkg -i                  || true
