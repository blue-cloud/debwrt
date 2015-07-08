# DebWrt - Debian on Embedded devices
#
# Copyright (C) 2013 Johan van Zoomeren <amain@debwrt.net>
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

PKG_NAME       = mjpg-streamer
PKG_VERSION    = 182
PKG_RELEASE    = 1

debian/package/$(PKG_NAME)/all: debian/package/$(PKG_NAME)/deliver
	touch $@

debian/package/$(PKG_NAME)/deliver: debian/package/$(PKG_NAME)/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/$(PKG_NAME)/*.deb     ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/$(PKG_NAME)/*.tar.gz  ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/$(PKG_NAME)/*.dsc     ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/$(PKG_NAME)/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/$(PKG_NAME)/rebuild: debian/package/$(PKG_NAME)/clean-build debian/package/$(PKG_NAME)/build

debian/package/$(PKG_NAME)/build: debian/package/$(PKG_NAME)/prepare
	$(call run_in_chroot,cd /usr/src/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION); \
                             dpkg-buildpackage -d -a${TARGET_ARCH} -rfakeroot)
	$(call run_in_chroot,find -maxdepth 1 -name '*.deb' | xargs -r -t -i sudo dpkg-cross -a ${TARGET_ARCH} -i {} || true)
	touch $@

debian/package/$(PKG_NAME)/prepare: debian/buildenv/create
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/$(PKG_NAME)
	cp -ar $(DEBIAN_PACKAGES_DIR)/$(PKG_NAME)/* $(DEBIAN_BUILD_DIR)/usr/src/$(PKG_NAME)
	rm -f $(DEBIAN_BUILD_DIR)/usr/src/$(PKG_NAME)/$(PKG_VERSION)/build.mk
	$(call run_in_chrootr,xapt --check-newer -k -a ${TARGET_ARCH} -m libjpeg8 libjpeg8-dev)
	$(call run_in_chroot ,cd /usr/src/$(PKG_NAME); \
                              dpkg-source -x $(PKG_NAME)_$(PKG_VERSION)-$(PKG_RELEASE).dsc)
	touch $@

debian/package/$(PKG_NAME)/clean-build:
	rm -f debian/package/$(PKG_NAME)/build

debian/package/$(PKG_NAME)/clean:
	rm -f debian/package/$(PKG_NAME)/all
	rm -f debian/package/$(PKG_NAME)/prepare
	rm -f debian/package/$(PKG_NAME)/build
	rm -f debian/package/$(PKG_NAME)/deliver
	rm -rf $(DEBIAN_BUILD_DIR)/usr/src/$(PKG_NAME)

.PHONY: debian/package/$(PKG_NAME)/clean \
        debian/package/$(PKG_NAME)/clean-build \
	debian/package/$(PKG_NAME)/rebuild

