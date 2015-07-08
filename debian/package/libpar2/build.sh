#!/bin/bash
#
# 1. Download package and unpack package
# 2. Copy debian/directory to it
# 3. Run dpkg-buildpackage --arch=<ARCH> -rfakeroot

if [ -z $ARCH                 ]; then echo "First set \$ARCH before running the build script"                ; exit 1; fi
if [ -z $DEBIAN_BUILD_VERSION ]; then echo "First set \$DEBIAN_BUILD_VERSION before running the build script"; exit 1; fi

export DEBFULLNAME="Amain (DebWrt.net)"
export LC_ALL=C
VERBOSE=1

[ "1" == $VERBOSE ] && set -x

PACKAGE=libpar2

BASE_DIR=/usr/src
BUILD_BASE_DIR=${BASE_DIR}/${PACKAGE}

# install build dependencies
apt-cross -S ${DEBIAN_BUILD_VERSION} -a ${ARCH} -i libsigc++-2.0-dev

# get the sources
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_BASE_DIR}
cd ${BUILD_BASE_DIR}
apt-get source libpar2
cd -

BSUBDIR=$(basename `find ${BUILD_BASE_DIR} -maxdepth 1 -name "${PACKAGE}-*" | head -1`)
BUILD_DIR=${BUILD_BASE_DIR}/$BSUBDIR

# apply patches
for patch in `ls ${BUILD_BASE_DIR}/patches | sort`; do
    patch -d ${BUILD_DIR} -p1 <${BUILD_BASE_DIR}/patches/$patch
done

# build debian package
cd ${BUILD_DIR}
dpkg-buildpackage -a${ARCH} -rfakeroot

# build and install deb cross packages
cd ${BUILD_BASE_DIR}
find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb"  | grep -v _all.deb | xargs -r -t sudo dpkg-cross -a ${ARCH} -b || true
find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb"  | grep    _all.deb | xargs -r -t sudo dpkg -i                  || true

