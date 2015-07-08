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

debian/package/shellinabox/all: debian/package/shellinabox/deliver
	touch $@

debian/package/shellinabox/deliver: debian/package/shellinabox/build
	mkdir -p ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/shellinabox/*.deb ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/shellinabox/*.tar.gz ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/shellinabox/*.dsc ${INSTALL_DIR_DEBIAN_PACKAGES}
	cp -rav $(DEBIAN_BUILD_DIR)/usr/src/shellinabox/*.changes ${INSTALL_DIR_DEBIAN_PACKAGES}
	touch $@

debian/package/shellinabox/build: debian/package/shellinabox/prepare
	$(CHROOT_USER) bash -c "cd /usr/src/shellinabox; export ARCH=$(TARGET_ARCH); ./build.sh"
	touch $@

debian/package/shellinabox/prepare: debian/buildenv/create
	rm -rf   $(DEBIAN_BUILD_DIR)/usr/src/shellinabox
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/shellinabox
	if [ -d $(DEBIAN_PACKAGES_DIR)/shellinabox/debian ]; then \
	    cp -ar $(DEBIAN_PACKAGES_DIR)/shellinabox/debian $(DEBIAN_BUILD_DIR)/usr/src/shellinabox; \
	fi
	if [ -d $(DEBIAN_PACKAGES_DIR)/shellinabox/patches ]; then \
	    cp -arv $(DEBIAN_PACKAGES_DIR)/shellinabox/patches $(DEBIAN_BUILD_DIR)/usr/src/shellinabox; \
	fi
	cp -ar $(DEBIAN_PACKAGES_DIR)/shellinabox/build.sh $(DEBIAN_BUILD_DIR)/usr/src/shellinabox
	touch $@

debian/package/shellinabox/clean:
	rm -f debian/package/shellinabox/all
	rm -f debian/package/shellinabox/build
	rm -f debian/package/shellinabox/prepare
	rm -f debian/package/shellinabox/deliver

