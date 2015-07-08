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

debian/package/iw/all: debian/package/iw/deliver
	touch $@

debian/package/iw/deliver: debian/package/iw/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/iw/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/iw/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/iw/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/iw/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/iw/build: debian/package/iw/prepare debian/package/libnl/all
	$(CHROOT_USER) bash -c "cd /usr/src/iw; export ARCH=$(TARGET_ARCH); ./iw.sh"
	touch $@

debian/package/iw/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/iw
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/iw
	cp -ar $(DEBIAN_PACKAGES_DIR)/iw/debian   $(DEBIAN_BUILD_DIR)/usr/src/iw
	cp -ar $(DEBIAN_PACKAGES_DIR)/iw/iw.sh $(DEBIAN_BUILD_DIR)/usr/src/iw
	touch $@

debian/package/iw/clean:
	rm -f debian/package/iw/all
	rm -f debian/package/iw/build
	rm -f debian/package/iw/prepare
	rm -f debian/package/iw/deliver
