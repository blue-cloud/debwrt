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

debian/package/debwrt-hostapd/all: debian/package/debwrt-hostapd/deliver
	touch $@

debian/package/debwrt-hostapd/deliver: debian/package/debwrt-hostapd/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapd/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapd/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapd/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapd/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/debwrt-hostapd/build: debian/package/debwrt-hostapd/prepare debian/package/libnl/all
	$(CHROOT_USER) bash -c "cd /usr/src/debwrt-hostapd; export ARCH=$(TARGET_ARCH); ./build.sh"
	touch $@

debian/package/debwrt-hostapd/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapd
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapd
	if [ -d $(DEBIAN_PACKAGES_DIR)/debwrt-hostapd/debian ]; then \
	    cp -ar $(DEBIAN_PACKAGES_DIR)/debwrt-hostapd/debian $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapd; \
	fi
	cp -a $(DEBIAN_PACKAGES_DIR)/debwrt-hostapd/patches   $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapd
	cp -ar $(DEBIAN_PACKAGES_DIR)/debwrt-hostapd/build.sh $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapd
	touch $@

debian/package/debwrt-hostapd/version:
	@rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapdversion
	@mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapdversion
	@svn checkout --quiet --depth files \
		svn://svn.openwrt.org/openwrt/trunk/package/hostapd \
		 $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapdversion
	@grep ^PKG_VERSION $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapdversion/Makefile
	@rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/debwrt-hostapdversion

debian/package/debwrt-hostapd/clean:
	rm -f debian/package/debwrt-hostapd/all
	rm -f debian/package/debwrt-hostapd/build
	rm -f debian/package/debwrt-hostapd/prepare
	rm -f debian/package/debwrt-hostapd/deliver

