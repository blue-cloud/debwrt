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

PACKAGE=nzbget
VERSION=trunk
RELEASE=1
DOWNLOAD_URL=https://nzbget.svn.sourceforge.net/svnroot/nzbget/${VERSION}

BASE_DIR=/usr/src
BUILD_BASE_DIR=${BASE_DIR}/${PACKAGE}
BUILD_DIR=${BUILD_BASE_DIR}/${PACKAGE}-${VERSION}
DOWNLOAD_DIR=${BASE_DIR}/dl

# install build deps
apt-cross -S ${DEBIAN_BUILD_VERSION} -a ${ARCH} -i libsigc++-2.0-dev libncurses5-dev libxml2-dev

# chechout sources
mkdir -p $DOWNLOAD_DIR
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
svn co ${DOWNLOAD_URL} ${BUILD_DIR}

# determine and set version
eval `cat ${BUILD_DIR}/configure | grep ^PACKAGE_VERSION=`
ORG_BUILD_DIR=${BUILD_DIR}
BUILD_DIR=${BUILD_BASE_DIR}/${PACKAGE}-${PACKAGE_VERSION}
mv ${ORG_BUILD_DIR} ${BUILD_DIR}

# apply patches
for patch in `ls ${BUILD_BASE_DIR}/patches 2>/dev/null | sort`; do
    patch -d ${BUILD_DIR} -p1 <${BUILD_BASE_DIR}/patches/$patch
done

# run dh_make first, if needed
if [ ! -d debian ]; then
   cd ${BUILD_DIR}
   dh_make -c gpl -e "amain@debwrt.net" -s -n
   echo "Please complete debian package configuration."
   exit 0
fi

cp -rav ${BUILD_BASE_DIR}/debian ${BUILD_DIR}

# build package
REV=`svnversion ${BUILD_DIR} | sed 's/[A-Z]//g' | sed 's/:.*$//'`
dch -v ${PACKAGE_VERSION}~r${REV}~Debwrt -b -m -t "Automated packet generation"
cd ${BUILD_DIR}
dpkg-buildpackage -a${ARCH} -rfakeroot

# build and install cross package
cd ${BUILD_BASE_DIR}
find ${BUILD_BASE_DIR} -maxdepth 1 -name "*.deb" | xargs -r -t sudo dpkg-cross -a ${ARCH} -i || true

