#!/bin/bash
#
# 1. Get files in the build environment
# 2. Copy debian/directory to it
# 3. Run dpkg-buildpackage --arch=<ARCH> -rfakeroot

export DEBFULLNAME="Geert Stappers"
export LC_ALL=C
VERBOSE=1

[ "1" == $VERBOSE ] && set -x

PACKAGE=led
VERSION=1.1
RELEASE=1
DEP=

BASE_DIR=/usr/src
BUILD_BASE_DIR=${BASE_DIR}/${PACKAGE}
BUILD_DIR=${BUILD_BASE_DIR}/${PACKAGE}-${VERSION}

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
cp -rav files/ ${BUILD_DIR}
cp -rav debian ${BUILD_DIR} | head -n 6  # copy all, but only show first lines
cd ${BUILD_DIR}
dpkg-buildpackage -a${ARCH} -rfakeroot
