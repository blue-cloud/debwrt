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

debian/package/libnl/all: debian/package/libnl/deliver 
	touch $@

debian/package/libnl/deliver: debian/package/libnl/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libnl/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libnl/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libnl/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libnl/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/libnl/build: debian/package/libnl/prepare debian/package/debwrt-kernel-headers/all
	#exit 1
	$(CHROOT_USER) bash -c "cd /usr/src/libnl; export ARCH=$(TARGET_ARCH); ./libnl.sh"
	touch $@

debian/package/libnl/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/libnl
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/libnl
	cp -ar $(DEBIAN_PACKAGES_DIR)/libnl/debian   $(DEBIAN_BUILD_DIR)/usr/src/libnl
	cp -ar $(DEBIAN_PACKAGES_DIR)/libnl/libnl.sh $(DEBIAN_BUILD_DIR)/usr/src/libnl
	touch $@

debian/package/libnl/clean:
	rm -f debian/package/libnl/all
	rm -f debian/package/libnl/build
	rm -f debian/package/libnl/prepare
	rm -f debian/package/libnl/deliver
