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

debian/package/swconfig/all: debian/package/swconfig/deliver
	touch $@

debian/package/swconfig/deliver: debian/package/swconfig/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/swconfig/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/swconfig/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/swconfig/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/swconfig/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/swconfig/build: debian/package/swconfig/prepare debian/package/libnl/all
	$(CHROOT_USER) bash -c "cd /usr/src/swconfig; export ARCH=$(TARGET_ARCH); ./build.sh"
	touch $@

debian/package/swconfig/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/swconfig
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/swconfig
	if [ -d $(DEBIAN_PACKAGES_DIR)/swconfig/debian ]; then \
	    cp -ar $(DEBIAN_PACKAGES_DIR)/swconfig/debian $(DEBIAN_BUILD_DIR)/usr/src/swconfig; \
	fi
	if [ -d $(DEBIAN_PACKAGES_DIR)/swconfig/patches ]; then \
		cp -arv $(DEBIAN_PACKAGES_DIR)/swconfig/patches $(DEBIAN_BUILD_DIR)/usr/src/swconfig; \
	fi
	cp -ar $(DEBIAN_PACKAGES_DIR)/swconfig/build.sh $(DEBIAN_BUILD_DIR)/usr/src/swconfig
	touch $@

debian/package/swconfig/clean:
	rm -f debian/package/swconfig/all
	rm -f debian/package/swconfig/build
	rm -f debian/package/swconfig/prepare
	rm -f debian/package/swconfig/deliver

