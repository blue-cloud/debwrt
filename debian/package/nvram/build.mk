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

debian/package/nvram/all: debian/package/nvram/deliver
	touch $@

debian/package/nvram/deliver: debian/package/nvram/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/nvram/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/nvram/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/nvram/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/nvram/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/nvram/build: debian/package/nvram/prepare
	$(CHROOT_USER) bash -c "cd /usr/src/nvram; export ARCH=$(TARGET_ARCH); ./build.sh"
	touch $@

debian/package/nvram/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/nvram
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/nvram
	if [ -d $(DEBIAN_PACKAGES_DIR)/nvram/debian ]; then \
	    cp -ar $(DEBIAN_PACKAGES_DIR)/nvram/debian $(DEBIAN_BUILD_DIR)/usr/src/nvram; \
	fi
	cp -ar $(DEBIAN_PACKAGES_DIR)/nvram/build.sh $(DEBIAN_BUILD_DIR)/usr/src/nvram
	touch $@

debian/package/nvram/clean:
	rm -f debian/package/nvram/all
	rm -f debian/package/nvram/build
	rm -f debian/package/nvram/prepare
	rm -f debian/package/nvram/deliver

