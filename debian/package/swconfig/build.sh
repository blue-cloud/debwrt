#!/bin/bash
#
# 1. Download package and unpack package
# 2. Copy debian/directory to it
# 3. Run dpkg-buildpackage --arch=<ARCH> -rfakeroot

set -e

if [ -z $ARCH ]; then echo "First set \$ARCH before running the build script"; exit 1; fi

export DEBFULLNAME="Amain (DebWrt.net)"
export LC_ALL=C
VERBOSE=1

[ "1" == $VERBOSE ] && set -x

PACKAGE=swconfig
VERSION=0.1
RELEASE=6
DOWNLOAD_URL=svn://svn.openwrt.org/openwrt/trunk/package/network/config/${PACKAGE}
DEP=

BASE_DIR=/usr/src
BUILD_BASE_DIR=${BASE_DIR}/${PACKAGE}
BUILD_DIR=${BUILD_BASE_DIR}/${PACKAGE}-${VERSION}
DOWNLOAD_DIR=${BASE_DIR}/dl

if ! ( dpkg --get-selections | grep libnl-tiny-dev )
then
   echo "libnl-tiny-dev package not installed"
   exit 1
fi

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
   cp -rav debian ${BUILD_DIR} | grep -v /.svn  # copy all, silence subversion
   cd ${BUILD_DIR}
   # build dependency checks broken for wheezy, checking it manually above
   dpkg-buildpackage -d -a${ARCH} -rfakeroot
   find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb"  | xargs -r -t -i sudo dpkg-cross -a ${ARCH} -i {} || true
fi

