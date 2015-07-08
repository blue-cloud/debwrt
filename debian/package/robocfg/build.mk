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

debian/package/robocfg/all: debian/package/robocfg/deliver
	touch $@

debian/package/robocfg/deliver: debian/package/robocfg/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/robocfg/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/robocfg/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/robocfg/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/robocfg/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/robocfg/build: debian/package/robocfg/prepare debian/package/libnl/all
	$(CHROOT_USER) bash -c "cd /usr/src/robocfg; export ARCH=$(TARGET_ARCH); ./build.sh"
	touch $@

debian/package/robocfg/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/robocfg
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/robocfg
	if [ -d $(DEBIAN_PACKAGES_DIR)/robocfg/debian ]; then \
	    cp -ar $(DEBIAN_PACKAGES_DIR)/robocfg/debian $(DEBIAN_BUILD_DIR)/usr/src/robocfg; \
	fi
	cp -ar $(DEBIAN_PACKAGES_DIR)/robocfg/build.sh $(DEBIAN_BUILD_DIR)/usr/src/robocfg
	touch $@

debian/package/robocfg/clean:
	rm -f debian/package/robocfg/all
	rm -f debian/package/robocfg/build
	rm -f debian/package/robocfg/prepare
	rm -f debian/package/robocfg/deliver

