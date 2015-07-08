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

DEBIAN_ROOTFS_INCLUDE_PACKAGES:=$(call qstrip,$(CONFIG_DEBIAN_ROOTFS_INCLUDE_PACKAGES))
DEBIAN_ROOTFS_QEMU_2ND_STAGE:=$(call qstrip, $(CONFIG_DEBIAN_ROOTFS_QEMU_2ND_STAGE))
DEBWRT_EXTRA_ROOTFS_FILES_DIR:=$(TOPDIR)/debian/rootfs/files
DEBWRT_MODULES_ARCHIVE=$(shell ls $(INSTALL_DIR)/debwrt-modules-*.tar.gz 2>/dev/null)
MODULES_VERSION=$(shell echo `basename $(DEBWRT_MODULES_ARCHIVE) 2>/dev/null` | awk -F '-' '{print $$6}')
DEBIAN_ROOTFS_INCLUDE_PACKAGES_DEBIAN_VERSION:=$(wildcard debian/rootfs/include_packages.list.$(DEBIAN_BUILD_VERSION))

define qemu-prepare
	@if [ ! -x $(QEMU_BIN_STATIC) ]; then echo "E: can't find qemu ($(QEMU_BIN_STATIC))"; fi
	@if [ ! -e /proc/sys/fs/binfmt_misc/qemu-$(TARGET_ARCH) ]; then echo "E: can't find binfmt_misc qemu-$(TARGET_ARCH) ( /proc/sys/fs/binfmt_misc/qemu-$(TARGET_ARCH)).\nE: install qemu-user-static, or\nE: disable second stage with qemu with menuconfig (DEBIAN_ROOTFS_QEMU_2ND_STAGE)."; fi
	@if [ ! -x $(QEMU_BIN_STATIC) -o ! -e /proc/sys/fs/binfmt_misc/qemu-$(TARGET_ARCH) ]; then echo "E: abort - qemu not available in chroot"; exit 1; fi
	@if [ ! -e $(ROOTFS_BUILD_DIR)$(QEMU_INTERPRETER) ]; then sudo cp $(QEMU_BIN_STATIC) $(ROOTFS_BUILD_DIR)$(QEMU_INTERPRETER); fi
	@if ! sudo chroot $(ROOTFS_BUILD_DIR) /bin/ls >/dev/null; then echo "E: qemu can't execute binaries for $(TARGET_ARCH)"; echo "E: abort"; exit 1; fi
	@if ! (mount | grep -q $(ROOTFS_BUILD_DIR)/proc); then sudo chroot $(ROOTFS_BUILD_DIR) mount -t proc none /proc; fi
	@if ! (mount | grep -q $(ROOTFS_BUILD_DIR)/sys ); then sudo chroot $(ROOTFS_BUILD_DIR) mount -t sysfs none /sys; fi
	@mount
endef

define qemu-cleanup
	@if (mount | grep -q $(ROOTFS_BUILD_DIR)/proc); then sudo umount $(ROOTFS_BUILD_DIR)/proc; fi
	@if (mount | grep -q $(ROOTFS_BUILD_DIR)/sys ); then sudo umount $(ROOTFS_BUILD_DIR)/sys ; fi
	@sudo rm -f $(ROOTFS_BUILD_DIR)$(QEMU_INTERPRETER)
endef

define rootfs-package-list
$(shell echo "$(DEBWRT_ROOTFS_PKGLST_DEPS)" \
         | tr ' ' '\n' \
         >$(TMP_DIR)/include_packages_list.debwrt-package-deps; \
        grep -hv '^#' \
         	 $(DEBIAN_ROOTFS_INCLUDE_PACKAGES) \
                 $(DEBIAN_ROOTFS_INCLUDE_PACKAGES_DEBIAN_VERSION) \
                 $(TMP_DIR)/include_packages_list.debwrt-package-deps \
          | sort -u | tr '\n' ',' | sed 's/,$$//')
endef

chr:
	$(call qemu-prepare)
	@sudo bash -c "echo "debwrt-$(TARGET_ARCH)" > $(ROOTFS_BUILD_DIR)/etc/debian_chroot"
	@sudo cp $(ROOTFS_BUILD_DIR)/etc/resolv.conf $(ROOTFS_BUILD_DIR)/etc/resolv.conf_debwrt
	@sudo bash -c "cat /etc/resolv.conf | grep nameserver >$(ROOTFS_BUILD_DIR)/etc/resolv.conf"
	@sudo chroot $(ROOTFS_BUILD_DIR)
	@sudo rm -f $(ROOTFS_BUILD_DIR)/etc/debian_chroot
	@sudo cp $(ROOTFS_BUILD_DIR)/etc/resolv.conf_debwrt $(ROOTFS_BUILD_DIR)/etc/resolv.conf
	$(call qemu-cleanup)

debian/rootfs: debian/rootfs/bootstrap            \
               debian/rootfs/unpack               \
               debian/rootfs/files-install        \
               debian/rootfs/debwrt-packages      \
               debian/rootfs/modules-install      \
               debian/rootfs/post-setup           \
               debian/rootfs/second-stage-qemu    \
	       debian/rootfs/verify               \
	       debian/rootfs/save
	@echo "I: root filesystem $(DEBIAN_BUILD_VERSION) $(TARGET_ARCH) prepared in $(ROOTFS_BUILD_DIR)"
	@echo "I: if the DebWrt kernel wasn't build, then no kernel modules have been installed, install them by:"
	@echo "I: - make openwrt/all"
	@echo "I: - make debian/rootfs/modules-install"
	@echo "I: - or: install manually from alternative source"
	@echo "I:"
	@echo "I: install the image to USB-Disk/USB-Stick/SD-Card (make sure it is already mounted at /media/DEBWRT_ROOTFS)"
	@echo "I: - make debian/rootfs/install"
	@echo "I:"
	@echo "I: enter the change root(with qemu) and perform additional post install steps:"
	@echo "I: - make chr"
	@echo "I: - apt-get update # example statement ;-) - networking works!"
	touch $@

debian/rootfs/install: debian/rootfs
	if [ -d /media/DEBWRT_ROOT ]; then \
		sudo rm -rf /media/DEBWRT_ROOT/*; \
		sudo bash -c "tar cf - -C $(ROOTFS_BUILD_DIR) . | tar xf - -C /media/DEBWRT_ROOT"; \
	fi
	#touch $@

debian/rootfs/verify:
	@if [ -f $(ROOTFS_BUILD_DIR)/debootstrap/debootstrap.log ]; then \
		echo "E: Second stage install was not completed successfully" ;\
		echo "E: Please check debootstrap.log to inspect the situation:" ;\
		echo "E:    make chr" ;\
		echo "E:    vi /debootstrap/debootstrap.log" ;\
		exit 1 ;\
	fi
	touch $@

debian/rootfs/save:
ifeq ($(DEBIAN_ROOTFS_QEMU_2ND_STAGE),y)
	sudo bash -c "tar cjf $(INSTALL_DIR)/$(ROOTFS_TAR_BZ2) -C $(ROOTFS_BUILD_DIR) ."
else
	if [ -d /media/DEBWRT_ROOT ]; then \
		sudo bash -c "tar cjf $(ROOTFS_TAR_BZ2) -C /media/DEBWRT_ROOT ."; \
	fi
endif

debian/rootfs/files-install: debian/rootfs/bootstrap
	if [ ! -f $(ROOTFS_BUILD_DIR)/etc/init.d/rcS.debian -a -e $(ROOTFS_BUILD_DIR)/etc/init.d/rcS ]; then \
		sudo mv -v $(ROOTFS_BUILD_DIR)/etc/init.d/rcS $(ROOTFS_BUILD_DIR)/etc/init.d/rcS.debian; \
	fi
	if [ ! -p $(ROOTFS_BUILD_DIR)/dev/initctl ]; then  \
		sudo mkdir -p $(ROOTFS_BUILD_DIR)/dev;         \
		sudo mkfifo   $(ROOTFS_BUILD_DIR)/dev/initctl; \
	fi
	chmod 600 $(DEBWRT_EXTRA_ROOTFS_FILES_DIR)/etc/ssh/ssh_host_rsa_key
	chmod 600 $(DEBWRT_EXTRA_ROOTFS_FILES_DIR)/etc/ssh/ssh_host_dsa_key
	sudo bash -c "tar cf - --exclude=".svn" -C $(DEBWRT_EXTRA_ROOTFS_FILES_DIR) . | tar -xovf - -C $(ROOTFS_BUILD_DIR)"
	sudo cat $(ROOTFS_BUILD_DIR)/etc/securetty \
		$(TOPDIR)/debian/rootfs/securetty.tail \
		>> $(TOPDIR)/securetty.temp
	sudo mv	$(TOPDIR)/securetty.temp $(ROOTFS_BUILD_DIR)/etc/securetty
	touch $@

debian/rootfs/modules-install: debian/rootfs/bootstrap
ifneq ($(DEBWRT_MODULES_ARCHIVE),)
	sudo tar xof $(DEBWRT_MODULES_ARCHIVE) -C $(ROOTFS_BUILD_DIR)
	#sudo depmod -a -b $(ROOTFS_BUILD_DIR) $(MODULES_VERSION)
else
	@echo "W: Can't install kernel module to the change root. Kernel modules archive missing. ($(DEBWRT_MODULES_ARCHIVE))"
endif
	touch $@

# Fow now: Include debwrt-packages dependencies staticly. This
#          list(DEBWRT_ROOTFS_PKGLST_DEPS) is managed in debian/package/debian.mk.
debian/rootfs/bootstrap: debian/rootfs/clean-rootfs-dir
	sudo debootstrap --arch=$(TARGET_ARCH)\
    	             --foreign \
        	     --include=$(call rootfs-package-list) \
            	     $(DEBIAN_BUILD_VERSION) \
     	             $(ROOTFS_BUILD_DIR) \
    	             $(CONFIG_DEBIAN_BUILDENV_REPOSITORY)
	# complete ROOTFS/dev/ with additional device files
	sudo bash -c "cd $(ROOTFS_BUILD_DIR)/dev ; /sbin/MAKEDEV -v consoleonly"
	sudo bash -c "cd $(ROOTFS_BUILD_DIR)/dev ; /sbin/MAKEDEV -v sda"
	touch $@

debian/rootfs/unpack: debian/rootfs/bootstrap
	find $(ROOTFS_BUILD_DIR) -name "*.deb" | while read deb; do \
		n=`basename $$deb`; \
		echo -n "I: Extracting $${n}..."; \
		sudo bash -c "dpkg --extract "$$deb" $(ROOTFS_BUILD_DIR)" ; \
		echo "done"; \
	done
	touch $@

# install all available cross-compiled debwrt debian packages, except for the kernel-headers package and the cross packages
debian/rootfs/debwrt-packages: debian/rootfs/bootstrap debian/package/rootfs
	ls ${INSTALL_DIR_DEBIAN_PACKAGES}/*.deb | grep -v "debwrt-kernel-headers" | grep -v "cross" | while read package; do \
		pfname=`basename $$package`; \
		pname=`echo $$pfname | sed 's/_.*//'`; \
		echo "Installing DebWrt package: $$pname"; \
		sudo cp $$package $(ROOTFS_BUILD_DIR)/var/cache/apt/archives; \
		sudo dpkg-deb -x $$package $(ROOTFS_BUILD_DIR); \
		sudo bash -c "echo \"$$pname /var/cache/apt/archives/$$pfname\" >>$(ROOTFS_BUILD_DIR)/debootstrap/debpaths" ;\
		sudo sed -i "s/$$/$$pname /" $(ROOTFS_BUILD_DIR)/debootstrap/base ;\
	done
	touch $@
	
debian/rootfs/clean-rootfs-dir:
	mkdir -p $(BUILD_DIR_BASE)
	sudo rm -rf $(ROOTFS_BUILD_DIR)
	touch $@

debian/rootfs/post-setup: debian/rootfs/bootstrap
	sudo mkdir -p $(ROOTFS_BUILD_DIR)/etc/apt
	# note: unfortunately /etc/apt/sources.list is cleaned after running second stage install
	sudo bash -c "echo \"deb http://ftp.debian.org/debian $(DEBIAN_BUILD_VERSION) main\" > $(ROOTFS_BUILD_DIR)/etc/apt/sources.list"
	sudo bash -c "echo \"$(DEBWRTVERSION)\" >$(ROOTFS_BUILD_DIR)/etc/debwrt_version"
	sudo bash -c "echo \"$(DEBIAN_BUILD_VERSION)\" >$(ROOTFS_BUILD_DIR)/etc/debian_release"
	touch $@

ifeq ($(DEBIAN_ROOTFS_QEMU_2ND_STAGE),y)
debian/rootfs/second-stage-qemu: debian/rootfs/bootstrap debian/buildenv/qemu-build
	$(call qemu-prepare)
	sudo chroot $(ROOTFS_BUILD_DIR) /usr/sbin/PostInstall && sudo rm -f $(ROOTFS_BUILD_DIR)/usr/sbin/PostInstall
	$(call qemu-cleanup)
else
debian/rootfs/second-stage-qemu: debian/rootfs/bootstrap
	@echo "I: Qemu 2nd stage install disabled. Second stage needs now to be performend on the target device itself."
	@echo "I: Qemu 2nd stage install can be enabled using menuconfig (DEBIAN_ROOTFS_QEMU_2ND_STAGE)."
endif
	touch $@

debian/rootfs/clean:
	sudo rm -rf $(ROOTFS_BUILD_DIR)
	rm -f debian/rootfs/debwrt-packages
	rm -f debian/rootfs/bootstrap
	rm -f debian/rootfs/install
	rm -f debian/rootfs/files-install
	rm -f debian/rootfs/modules-install

