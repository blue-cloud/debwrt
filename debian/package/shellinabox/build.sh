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

PACKAGE=shellinabox
VERSION=trunk
RELEASE=1
DOWNLOAD_URL="http://shellinabox.googlecode.com/svn/trunk/"

BASE_DIR=/usr/src
BUILD_BASE_DIR=${BASE_DIR}/${PACKAGE}
BUILD_DIR=${BUILD_BASE_DIR}/${PACKAGE}-${VERSION}
DOWNLOAD_DIR=${BASE_DIR}/dl

# install build dependencies
sudo apt-get -y install binutils libssl-dev libpam0g-dev libz-dev

mkdir -p $DOWNLOAD_DIR
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
svn co ${DOWNLOAD_URL} ${BUILD_DIR}

# apply patches
for patch in `ls ${BUILD_BASE_DIR}/patches | sort`; do
    patch -d ${BUILD_DIR} -p1 <${BUILD_BASE_DIR}/patches/$patch
done

cd ${BUILD_DIR}
# add -d: ignore build dependency check. Somehow dpkg-cross is not creating proper packages anymore, 
#         or dpkg-buildpackage does not understand dpkg-cross package naming scheme anymore.
dpkg-buildpackage -d -a${ARCH} -rfakeroot
find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb"  | xargs -r -t -i sudo dpkg-cross -a ${ARCH} -i {} || true

