# DebWrt - Debian on Embedded devices
#
# Copyright (C) 2010 Johan van Zoomeren <amain@debwrt.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

RELEASE:=testing
BUILD_CYCLE_ID:=-1
VERSION:=2.1$(BUILD_CYCLE_ID)
RELEASE_DATE=$(shell LC_ALL=c date +"%d %B %Y")
SVN_REVISION:=$(call get_svn_revision)
DEBWRTVERSION:=$(RELEASE) - $(VERSION) - [ $(RELEASE_DATE) ($(SVN_REVISION)) ]
DEBWRT_VERSION:=$(RELEASE)-$(VERSION)

empty:=
space:= $(empty) $(empty)

# Include DebWrt config
-include $(TOPDIR)/.config

# Target arch
TARGET_ARCH:=$(call qstrip,$(CONFIG_ARCH))

# Board [example: ar7xx]
BOARD:=$(call qstrip,$(CONFIG_TARGET_BOARD))

# Sub board [example: ubnt-rspro]
SUB_BOARD:=$(shell $(SCRIPT_GET_BOARD) $(TOPDIR)/.config $(BOARD))

# Linux version [2.6.X(.X)]
LINUX_VERSION:=$(call qstrip,$(CONFIG_DEBWRT_KERNEL_VERSION))

# OpenWrt Branch to checkout [trunk|<otherbranchname>]
OPENWRT_BRANCH:=$(call qstrip,$(CONFIG_OPENWRT_BRANCH))

# OpenWrt Release Tag to checkout
OPENWRT_TAG:=$(call qstrip,$(CONFIG_OPENWRT_TAG))

# OpenWrt Revision to checkout [suitable for `svn -r XXXXX`]
OPENWRT_REVISION:=$(call qstrip,$(CONFIG_OPENWRT_REVISION))

# Base BuildDir
BUILD_DIR_BASE:=$(TOPDIR)/build

# Config dir
CONFIG_DIR:=$(TOPDIR)/config

# Plugins dir
PLUGINS_DIR:=$(TOPDIR)/plugins

# bin/delivery dir
BIN_DIR:=$(TOPDIR)/bin

# tmp dir
TMP_DIR:=$(TOPDIR)/tmp

# Install dir
INSTALL_DIR:=$(BIN_DIR)/$(BOARD)-$(SUB_BOARD)-$(DEBWRT_VERSION)

# Install dir for OpenWrt binaries
INSTALL_DIR_OPENWRT:=$(INSTALL_DIR)/openwrt

# Install dir OpenWrt kernel modules
INSTALL_DIR_OPENWRT_MODULES:=$(INSTALL_DIR_OPENWRT)/modules

# Install dir OpenWrt packages
INSTALL_DIR_OPENWRT_PACKAGES:=$(INSTALL_DIR_OPENWRT)/packages

# Install dic OpenWrt kernel headers
INSTALL_DIR_OPENWRT_HEADERS:=$(INSTALL_DIR_OPENWRT)/headers

# Image file containing OpenWrt kernel modules
MODULES_TAR_GZ=debwrt-modules-$(BOARD)-$(SUB_BOARD)-$(OPENWRT_LINUX_UNAME_VERSION)-$(DEBWRT_VERSION).tar.gz

# Image file containing OpenWrt kernel headers
HEADERS_TAR_GZ=debwrt-headers-$(BOARD)-$(SUB_BOARD)-$(OPENWRT_LINUX_UNAME_VERSION)-$(DEBWRT_VERSION).tar.gz

# Image file containing DebWrt rootfs
ROOTFS_TAR_BZ2=debwrt-rootfs-$(BOARD)-$(SUB_BOARD)-$(OPENWRT_LINUX_UNAME_VERSION)-$(DEBWRT_VERSION).tar.bz2

# Filename of DebWrt firmware image
TARGET_IMAGE_NAME_BIN=debwrt-firmware-$(BOARD)-$(SUB_BOARD)-$(OPENWRT_LINUX_UNAME_VERSION)-$(DEBWRT_VERSION).bin
TARGET_IMAGE_NAME_TRX=debwrt-firmware-$(BOARD)-$(SUB_BOARD)-$(OPENWRT_LINUX_UNAME_VERSION)-$(DEBWRT_VERSION).trx

# OpenWrt patches directory
PATCHES_DIR_OPENWRT=$(TOPDIR)/openwrt/patches

# OpenWrt files directory
FILES_DIR_OPENWRT=$(TOPDIR)/openwrt/files

# OpenWrt Build (checkout) directory
ifeq ($(OPENWRT_TAG),)
OPENWRT_BUILD_DIR:=$(BUILD_DIR_BASE)/openwrt-$(BOARD)-$(SUB_BOARD)-$(OPENWRT_BRANCH)-$(OPENWRT_REVISION)
else
OPENWRT_BUILD_DIR:=$(BUILD_DIR_BASE)/openwrt-$(BOARD)-$(SUB_BOARD)-$(OPENWRT_TAG)
endif

# Special saved environment variables during OpenWrt's build process
OPENWRT_SAVE_CONFIG_FILE:=$(OPENWRT_BUILD_DIR)/.openwrt_env

# Alternate OpenWrt download directory
OPENWRT_DOWNLOAD_DIR:=$(call qstrip,$(CONFIG_OPENWRT_DOWNLOAD_DIR))

# Debian build environment version
DEBIAN_BUILD_VERSION:=$(call qstrip,$(CONFIG_DEBWRT_DEBIAN_RELEASE))

# Debian
DEBIAN_BUILD_DIR:=$(BUILD_DIR_BASE)/debian-$(BOARD)-$(SUB_BOARD)-$(DEBIAN_BUILD_VERSION)

# Debian packages dir
DEBIAN_PACKAGES_DIR:=$(TOPDIR)/debian/package
INSTALL_DIR_DEBIAN_PACKAGES:=$(INSTALL_DIR)/debian

# Debian rootfs
ROOTFS_BUILD_DIR:=$(BUILD_DIR_BASE)/rootfs-$(TARGET_ARCH)-$(DEBWRT_VERSION)

# Export defaults to other Makefiles
export

$(TMP_DIR) $(BIN_DIR) $(OPENWRT_BUILD_DIR) $(BUILD_DIR_BASE) $(INSTALL_DIR_BASE) $(INSTALL_DIR_OPENWRT) $(INSTALL_DIR_DEBIAN):
	mkdir -p $@

