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

debian/package/broadcom-wl/all: debian/package/broadcom-wl/deliver
	touch $@

debian/package/broadcom-wl/deliver: debian/package/broadcom-wl/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/broadcom-wl/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/broadcom-wl/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/broadcom-wl/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/broadcom-wl/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/broadcom-wl/build: debian/package/broadcom-wl/prepare
	$(CHROOT_USER) bash -c "cd /usr/src/broadcom-wl; export ARCH=$(TARGET_ARCH); ./build.sh"
	touch $@

debian/package/broadcom-wl/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/broadcom-wl
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/broadcom-wl
	if [ -d $(DEBIAN_PACKAGES_DIR)/broadcom-wl/debian ]; then \
	    cp -ar $(DEBIAN_PACKAGES_DIR)/broadcom-wl/debian $(DEBIAN_BUILD_DIR)/usr/src/broadcom-wl; \
	fi
	if [ -d $(DEBIAN_PACKAGES_DIR)/broadcom-wl/patches ]; then \
		cp -arv $(DEBIAN_PACKAGES_DIR)/broadcom-wl/patches $(DEBIAN_BUILD_DIR)/usr/src/broadcom-wl; \
	fi
	cp -ar $(DEBIAN_PACKAGES_DIR)/broadcom-wl/build.sh $(DEBIAN_BUILD_DIR)/usr/src/broadcom-wl
	touch $@

debian/package/broadcom-wl/clean:
	rm -f debian/package/broadcom-wl/all
	rm -f debian/package/broadcom-wl/build
	rm -f debian/package/broadcom-wl/prepare
	rm -f debian/package/broadcom-wl/deliver

