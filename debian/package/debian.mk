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

run_in_chroot              = $(CHROOT_USER) bash -c "cd /usr/src/$(PKG_NAME); export ARCH=$(TARGET_ARCH); $(1)"
run_in_chrootr             = $(CHROOT)      bash -c "cd /usr/src/$(PKG_NAME); export ARCH=$(TARGET_ARCH); $(1)"

CH                        := "[\(\)]"

DEBWRT_ROOTFS_PKGLST      := libnl iw debwrt-kernel-headers robocfg nvram \
		             debwrt-hostapd shellinabox libnl-tiny swconfig \
		             broadcom-wl debwrt-net mjpg-streamer

DEBWRT_ROOTFS_PKGLST_DEPS := libjpeg8

debian/package/rootfs:
	for pkg in $(DEBWRT_ROOTFS_PKGLST); do \
		$(MAKE) -f debian/package/$${pkg}/build.mk debian/package/$${pkg}/all; \
		if [ ! 0 -eq $$? ]; then echo "Failed building package for rootfs: $${pkg}"; exit 1; fi; \
	done
	touch $@

debian/package/clean:
	rm -rf $(DEBIAN_BUILD_DIR)/usr/src/*	
	rm -f $(TOPDIR)/debian/package/rootfs
	rm -f $(TOPDIR)/debian/package/*/build
	rm -f $(TOPDIR)/debian/package/*/prepare
	rm -f $(TOPDIR)/debian/package/*/deliver

debian/package/%:
	echo make me: $@
	$(MAKE) -f debian/package/$(dir $(subst debian/package/,,$@))build.mk $@

