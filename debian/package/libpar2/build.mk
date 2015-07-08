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

debian/package/libpar2/all: debian/package/libpar2/deliver
	touch $@

debian/package/libpar2/deliver: debian/package/libpar2/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libpar2/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libpar2/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libpar2/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/libpar2/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/libpar2/build: debian/package/libpar2/prepare
	$(CHROOT_USER) bash -c "cd /usr/src/libpar2; export ARCH=$(TARGET_ARCH); export DEBIAN_BUILD_VERSION=$(DEBIAN_BUILD_VERSION); ./build.sh"
	touch $@

debian/package/libpar2/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/libpar2
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/libpar2
	if [ -d $(DEBIAN_PACKAGES_DIR)/libpar2/debian ]; then \
	    cp -ar $(DEBIAN_PACKAGES_DIR)/libpar2/debian $(DEBIAN_BUILD_DIR)/usr/src/libpar2; \
	fi
	if [ -d $(DEBIAN_PACKAGES_DIR)/libpar2/patches ]; then \
	    cp -arv $(DEBIAN_PACKAGES_DIR)/libpar2/patches $(DEBIAN_BUILD_DIR)/usr/src/libpar2; \
	fi
	cp -ar $(DEBIAN_PACKAGES_DIR)/libpar2/build.sh $(DEBIAN_BUILD_DIR)/usr/src/libpar2
	touch $@

debian/package/libpar2/clean:
	rm -f debian/package/libpar2/all
	rm -f debian/package/libpar2/build
	rm -f debian/package/libpar2/prepare
	rm -f debian/package/libpar2/deliver

