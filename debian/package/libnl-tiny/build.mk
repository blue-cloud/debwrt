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

debian/package/libnl-tiny/all: debian/package/libnl-tiny/deliver
	touch $@

debian/package/libnl-tiny/deliver: debian/package/libnl-tiny/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libnl-tiny/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libnl-tiny/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libnl-tiny/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libnl-tiny/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/libnl-tiny/build: debian/package/libnl-tiny/prepare debian/package/libnl/all
	$(CHROOT_USER) bash -c "cd /usr/src/libnl-tiny; export ARCH=$(TARGET_ARCH); ./build.sh"
	touch $@

debian/package/libnl-tiny/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/libnl-tiny
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/libnl-tiny
	if [ -d $(DEBIAN_PACKAGES_DIR)/libnl-tiny/debian ]; then \
	    cp -ar $(DEBIAN_PACKAGES_DIR)/libnl-tiny/debian $(DEBIAN_BUILD_DIR)/usr/src/libnl-tiny; \
	fi
	if [ -d $(DEBIAN_PACKAGES_DIR)/libnl-tiny/patches ]; then \
		cp -arv $(DEBIAN_PACKAGES_DIR)/libnl-tiny/patches $(DEBIAN_BUILD_DIR)/usr/src/libnl-tiny; \
	fi
	cp -ar $(DEBIAN_PACKAGES_DIR)/libnl-tiny/build.sh $(DEBIAN_BUILD_DIR)/usr/src/libnl-tiny
	touch $@

debian/package/libnl-tiny/clean:
	rm -f debian/package/libnl-tiny/all
	rm -f debian/package/libnl-tiny/build
	rm -f debian/package/libnl-tiny/prepare
	rm -f debian/package/libnl-tiny/deliver

