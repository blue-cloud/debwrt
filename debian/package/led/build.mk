# DebWrt - Debian on OpenWRT devices
#
# Copyright (C) 2011 Geert Stappers <stappers@stappers.it>
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

debian/package/led/all: debian/package/led/deliver
	touch $@

debian/package/led/deliver: debian/package/led/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp $(DEBIAN_BUILD_DIR)/usr/src/led/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp $(DEBIAN_BUILD_DIR)/usr/src/led/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp $(DEBIAN_BUILD_DIR)/usr/src/led/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp $(DEBIAN_BUILD_DIR)/usr/src/led/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/led/build: debian/package/led/prepare
	$(CHROOT_USER) bash \
		-c "cd /usr/src/led; export ARCH=$(TARGET_ARCH); ./build.sh"
	touch $@

debian/package/led/prepare: # debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/led
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/led
	cp -a $(DEBIAN_PACKAGES_DIR)/led/files  $(DEBIAN_BUILD_DIR)/usr/src/led
	mv $(DEBIAN_BUILD_DIR)/usr/src/led/files/* $(DEBIAN_BUILD_DIR)/usr/src/led
	rmdir $(DEBIAN_BUILD_DIR)/usr/src/led/files
	cp -a $(DEBIAN_PACKAGES_DIR)/led/debian $(DEBIAN_BUILD_DIR)/usr/src/led
	cp $(DEBIAN_PACKAGES_DIR)/led/build.sh $(DEBIAN_BUILD_DIR)/usr/src/led
	touch $@

debian/package/led/clean:
	rm -f debian/package/led/all
	rm -f debian/package/led/build
	rm -f debian/package/led/prepare
	rm -f debian/package/led/deliver
