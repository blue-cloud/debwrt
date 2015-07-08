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

debian/package/nzbget/all: debian/package/nzbget/deliver
	touch $@

debian/package/nzbget/deliver: debian/package/nzbget/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/nzbget/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/nzbget/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/nzbget/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/nzbget/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/nzbget/build: debian/package/nzbget/prepare debian/package/libpar2/build
	$(CHROOT_USER) bash -c "cd /usr/src/nzbget; export ARCH=$(TARGET_ARCH); export DEBIAN_BUILD_VERSION=$(DEBIAN_BUILD_VERSION); ./build.sh"
	touch $@

debian/package/nzbget/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/nzbget
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/nzbget
	if [ -d $(DEBIAN_PACKAGES_DIR)/nzbget/debian ]; then \
	    cp -ar $(DEBIAN_PACKAGES_DIR)/nzbget/debian $(DEBIAN_BUILD_DIR)/usr/src/nzbget; \
	fi
	if [ -d $(DEBIAN_PACKAGES_DIR)/nzbget/patches ]; then \
	    cp -arv $(DEBIAN_PACKAGES_DIR)/nzbget/patches $(DEBIAN_BUILD_DIR)/usr/src/nzbget; \
	fi
	cp -ar $(DEBIAN_PACKAGES_DIR)/nzbget/build.sh $(DEBIAN_BUILD_DIR)/usr/src/nzbget
	touch $@

debian/package/nzbget/clean:
	rm -f debian/package/nzbget/all
	rm -f debian/package/nzbget/build
	rm -f debian/package/nzbget/prepare
	rm -f debian/package/nzbget/deliver

