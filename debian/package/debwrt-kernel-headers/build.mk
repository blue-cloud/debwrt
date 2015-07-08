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

include $(TOPDIR)/Makefile

debian/package/debwrt-kernel-headers/all: openwrt/deliver/check debian/package/debwrt-kernel-headers/deliver
	touch $@

debian/package/debwrt-kernel-headers/deliver: debian/package/debwrt-kernel-headers/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/debwrt-kernel-headers/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	#cp -rav $(DEBIAN_BUILD_DIR)/usr/src/debwrt-kernel-headers/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/debwrt-kernel-headers/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	#cp -rav $(DEBIAN_BUILD_DIR)/usr/src/debwrt-kernel-headers/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/debwrt-kernel-headers/build: debian/package/debwrt-kernel-headers/prepare
	$(CHROOT_USER) bash -c "cd /usr/src/debwrt-kernel-headers; export ARCH=$(TARGET_ARCH); ./debwrt-kernel-headers.sh"
	touch $@

debian/package/debwrt-kernel-headers/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/debwrt-kernel-headers
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/debwrt-kernel-headers
	cp -ar $(DEBIAN_PACKAGES_DIR)/debwrt-kernel-headers/debian   $(DEBIAN_BUILD_DIR)/usr/src/debwrt-kernel-headers
	cp -ar $(DEBIAN_PACKAGES_DIR)/debwrt-kernel-headers/debwrt-kernel-headers.sh  $(DEBIAN_BUILD_DIR)/usr/src/debwrt-kernel-headers
	if [ -f $(INSTALL_DIR)/$(HEADERS_TAR_GZ) ]; then \
		cp $(INSTALL_DIR)/$(HEADERS_TAR_GZ) $(DEBIAN_BUILD_DIR)/usr/src/debwrt-kernel-headers; \
	else \
	        echo "E: please build OpenWrt first - we will be needing the kernel headers" ;\
		echo "E: Can't locate $(INSTALL_DIR)/$(HEADERS_TAR_GZ)" ;\
	        exit 1 ;\
	fi
	touch $@

debian/package/debwrt-kernel-headers/clean:
	rm -f debian/package/debwrt-kernel-headers/build
	rm -f debian/package/debwrt-kernel-headers/build
	rm -f debian/package/debwrt-kernel-headers/prepare
	rm -f debian/package/debwrt-kernel-headers/deliver

