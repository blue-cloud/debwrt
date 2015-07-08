#!/bin/bash
#
# 1. Download package and unpack package
# 2. Copy debian/directory to it
# 3. Run dpkg-buildpackage --arch=<ARCH> -rfakeroot

if [ -z $ARCH ]; then echo "First set \$ARCH before running the build script"; exit 1; fi

export DEBFULLNAME="Amain (DebWrt.net)"
export LC_ALL=C
VERBOSE=1

[ "1" == $VERBOSE ] && set -x

PACKAGE=nvram
VERSION=1.0
RELEASE=1
DOWNLOAD_URL=svn://svn.openwrt.org/openwrt/trunk/package/utils/nvram
DEP=

BASE_DIR=/usr/src
BUILD_BASE_DIR=${BASE_DIR}/${PACKAGE}
BUILD_DIR=${BUILD_BASE_DIR}/${PACKAGE}-${VERSION}
DOWNLOAD_DIR=${BASE_DIR}/dl

mkdir -p $DOWNLOAD_DIR
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
svn co ${DOWNLOAD_URL} ${BUILD_DIR}

if [ ! -d debian ]; then
   cd ${BUILD_DIR} 
   dh_make -c gpl -e "amain@debwrt.net" -l -n
   echo "Please complete debian package configuration. And copy the files back to the svn working directory."
   exit 1
else
   cp -rav debian ${BUILD_DIR}
   cd ${BUILD_DIR}
   dpkg-buildpackage -a${ARCH} -rfakeroot
   find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb"  | xargs -r -t -i sudo dpkg-cross -a ${ARCH} -i {} || true
fi

