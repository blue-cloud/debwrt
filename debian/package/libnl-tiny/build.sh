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

PACKAGE=libnl-tiny
VERSION=0.1
RELEASE=1
DOWNLOAD_URL=svn://svn.openwrt.org/openwrt/trunk/package/libs/${PACKAGE}
DEP=

BASE_DIR=/usr/src
BUILD_BASE_DIR=${BASE_DIR}/${PACKAGE}
BUILD_DIR=${BUILD_BASE_DIR}/${PACKAGE}-${VERSION}
DOWNLOAD_DIR=${BASE_DIR}/dl

mkdir -p $DOWNLOAD_DIR
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
svn co ${DOWNLOAD_URL} ${BUILD_DIR}

# apply patches
for patch in `ls ${BUILD_BASE_DIR}/patches | sort`; do
    patch -d ${BUILD_DIR} -p1 <${BUILD_BASE_DIR}/patches/$patch
done

if [ ! -d debian ]; then
   cd ${BUILD_DIR} 
   dh_make -c gpl -e "amain@debwrt.net" -s -n
   echo "Please complete debian package configuration. When done: cp -ra ${BUILD_DIR}/debian ."
else
   cp -rav debian ${BUILD_DIR}
   cd ${BUILD_DIR}
   dpkg-buildpackage -a${ARCH} -rfakeroot

   # build and install deb cross packages
   cd ${BUILD_BASE_DIR}
   find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb"  | grep -v _all.deb | xargs -r -t sudo dpkg-cross -a ${ARCH} -b || true
   find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb"  | grep    _all.deb | xargs -r -t sudo dpkg -i                  || true
fi

