#!/bin/bash
#
# 1. Download package and unpack package
# 2. Copy debian/directory to it
# 3. Run dpkg-buildpackage --arch=<ARCH> -rfakeroot

if [ -z $ARCH ]; then echo "First set \$ARCH before running the build script"; exit 1; fi

export DEBFULLNAME="Amain (DebWrt.net)"
export LC_ALL=C
VERBOSE=0

[ "1" == $VERBOSE ] && set -x

PACKAGE=broadcom-wl
VERSION=1
RELEASE=1
DOWNLOAD_URL=svn://svn.openwrt.org/openwrt/trunk/package/kernel/${PACKAGE}
DEP=

BASE_DIR=/usr/src
BUILD_BASE_DIR=${BASE_DIR}/${PACKAGE}
BUILD_DIR=${BUILD_BASE_DIR}/${PACKAGE}-${VERSION}
DOWNLOAD_DIR=${BASE_DIR}/dl

mkdir -p $DOWNLOAD_DIR
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
svn checkout ${DOWNLOAD_URL} ${BUILD_DIR}

# PKG_NAME:=broadcom-wl
# PKG_VERSION:=5.10.56.27.3
# PKG_RELEASE:=1
# 
# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(ARCH).tar.bz2
# PKG_SOURCE_URL:=http://downloads.openwrt.org/sources

VERSION=`cat ${BUILD_DIR}/Makefile  | grep ^PKG_VERSION | awk -F ":=" '{print $2}'`
RELEASE=`cat ${BUILD_DIR}/Makefile  | grep ^PKG_RELEASE | awk -F ":=" '{print $2}'`

NEW_BUILD_DIR=${BUILD_BASE_DIR}/${PACKAGE}-${VERSION}
mv ${BUILD_DIR} ${NEW_BUILD_DIR}
BUILD_DIR=${NEW_BUILD_DIR}

PACKAGE_SOURCE=${PACKAGE}-${VERSION}_$ARCH.tar.bz2
DOWNLOAD_URL2=http://mirror2.openwrt.org/sources/${PACKAGE_SOURCE}

if [ ! -s ${DOWNLOAD_DIR}/${PACKAGE_SOURCE} ]; then rm -f ${DOWNLOAD_DIR}/${PACKAGE_SOURCE}; wget -O ${DOWNLOAD_DIR}/${PACKAGE_SOURCE} $DOWNLOAD_URL2; fi
#mkdir -p ${BUILD_DIR}/src
tar xjf ${DOWNLOAD_DIR}/${PACKAGE_SOURCE} -C ${BUILD_DIR} --strip 1

# apply openwrt patches
for patch in `ls ${BUILD_DIR}/patches | sort`; do
    patch -d ${BUILD_DIR} -p1 <${BUILD_DIR}/patches/$patch
done

# apply debwrt patches, if any
for patch in $( ls patches/*.diff )
do
    echo "I:patch file = ${patch}"
    patch -d ${BUILD_DIR} -p0 < ${patch}
done

if [ ! -d debian ]; then
   cd ${BUILD_DIR} 
   dh_make -c gpl -e "amain@debwrt.net" -s -n
   echo "Please complete debian package configuration. And copy the files back to the svn working directory."
   exit 1
else
   cp -a debian ${BUILD_DIR}
   cd ${BUILD_DIR}
   dch -v ${VERSION}-${RELEASE} -m -t "Automated packet generation"
   dpkg-buildpackage -a${ARCH} -rfakeroot
   find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb"  | xargs -r -t -i sudo dpkg-cross -a ${ARCH} -i {} || true
fi
