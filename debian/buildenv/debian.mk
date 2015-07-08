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

SB2_ARCH:=$(call qstrip,$(CONFIG_ARCH))
CHROOT:=sudo chroot $(DEBIAN_BUILD_DIR)
CHROOT_USER:=$(CHROOT) su - $(USER)
SB2:=sudo chroot $(DEBIAN_BUILD_DIR) su - $(USER) -c bash -c "export LC_ALL=C; cd $(SB2_ARCH)-lenny && sb2"
SB2E:=sudo chroot $(DEBIAN_BUILD_DIR) su - $(USER) -c bash -c "export LC_ALL=C; cd $(SB2_ARCH)-lenny && sb2 -e"
SB2EF:=sudo chroot $(DEBIAN_BUILD_DIR) su - $(USER) -c bash -c "export LC_ALL=C; cd $(SB2_ARCH)-lenny && sb2 -eR"
QEMU_BIN=$(DEBIAN_BUILD_DIR)/usr/local/bin/qemu-$(TARGET_ARCH)
QEMU_BIN_STATIC=$(QEMU_BIN)-static
QEMU_INTERPRETER=$(shell cat /proc/sys/fs/binfmt_misc/qemu-$(TARGET_ARCH) 2>/dev/null | grep interpreter | awk '{print $$2}')

sb2:
	$(SB2)
sb2e:
	$(SB2E)
sbef:
	$(SB2EF)
ch: chroot
chu: chroot-user
chroot:
	$(CHROOT) bash -c "cd /usr/src; exec bash"
chroot-user:
	$(CHROOT_USER) bash -c "cd /usr/src; exec bash"

debian/buildenv/create: debian/buildenv/prepare debian/buildenv/emdebian-prepare debian/buildenv/qemu-build
	touch $@

debian/buildenv/prepare:
	mkdir -p $(DEBIAN_BUILD_DIR)
	# Due to various bugs in debootstrap in combination with fakechroot it is not 
	# possible to create a fakechroot here - and therefore we need to use chroot
	# with sudo
	#fakeroot fakechroot debootstrap 
						#--variant=fakechroot 
	sudo debootstrap    --include=$(subst $(space),$(empty),$(CONFIG_DEBIAN_BUILDENV_INCLUDE_PACKAGES)) \
					    $(DEBIAN_BUILD_VERSION) \
						$(DEBIAN_BUILD_DIR) \
						$(CONFIG_DEBIAN_BUILDENV_REPOSITORY)
	sudo bash -c "echo 127.0.0.1 `hostname -s` localhost >$(DEBIAN_BUILD_DIR)/etc/hosts"
	sudo bash -c "echo debwrt-$(TARGET_ARCH)-$(DEBIAN_BUILD_VERSION) > $(DEBIAN_BUILD_DIR)/etc/debian_chroot"
	sudo bash -c "echo syntax on >$(DEBIAN_BUILD_DIR)/etc/vimrc"
	sudo bash -c "echo 0 > /proc/sys/vm/mmap_min_addr" # for ARM targets
	sudo bash -c "echo \"deb $(call qstrip,$(CONFIG_DEBIAN_BUILDENV_REPOSITORY)) $(DEBIAN_BUILD_VERSION) main\" >> $(DEBIAN_BUILD_DIR)/etc/apt/sources.list"
	sudo bash -c "echo \"deb-src $(call qstrip,$(CONFIG_DEBIAN_BUILDENV_REPOSITORY)) $(DEBIAN_BUILD_VERSION) main\" >> $(DEBIAN_BUILD_DIR)/etc/apt/sources.list"
	sudo chown $(USER):$(GROUP) $(DEBIAN_BUILD_DIR)/usr/src
	sudo chroot $(DEBIAN_BUILD_DIR) apt-get update
	sudo chroot $(DEBIAN_BUILD_DIR) groupadd -g $(shell id -g) debwrt
	sudo chroot $(DEBIAN_BUILD_DIR) useradd -g debwrt -s /bin/bash -m -u $(shell id -u) $$USER
	sudo mkdir -p $(DEBIAN_BUILD_DIR)/etc/sudoers.d
	sudo bash -c "echo \"$(USER) ALL=(ALL) NOPASSWD: ALL\" >$(DEBIAN_BUILD_DIR)/etc/sudoers.d/debwrt"
	sudo chmod 0440 $(DEBIAN_BUILD_DIR)/etc/sudoers.d/debwrt
	touch $@

debian/buildenv/prepare-sb2:
	sudo chroot $(DEBIAN_BUILD_DIR) bash -c "export LC_ALL=C; apt-get -y --force-yes install g++-4.3-$(SB2_ARCH)-linux-gnu libc6-dev-$(SB2_ARCH)-cross build-essential debootstrap fakeroot zlib1g-dev qemu-user scratchbox2 dh-make"
	touch $@

#
# -- Emdebian sources.list entries
#
# deb http://www.emdebian.org/debian/ unstable main
# deb http://www.emdebian.org/debian/ testing main
# deb http://www.emdebian.org/debian/ lenny main
#
# Once you have that then install whichever version of the tools you want. e.g:
# apt-get install libc6-armel-cross libc6-dev-armel-cross binutils-arm-linux-gnueabi gcc-4.3-arm-linux-gnueabi g++-4.3-arm-linux-gnueabi
# will install the gcc-4.3 C and C++ toolchain for armel cross-compiling.
#
# Use emdebian stable/lenny cross compiler. Unstable seems to be broken now for a long time
#
# Emdebian suggests to use squeeze, even if on wheezey or higher:
# Currently, toolchains for Squeeze are preferred. If using Wheezy or unstable, add 
# a Squeeze source for your own architecture using your normal Debian mirror for 
# dependencies which are no longer in wheezy or unstable.
#
#EMDEBIAN_RELEASE:=$(DEBIAN_BUILD_VERSION)
EMDEBIAN_RELEASE:=squeeze

# Automatic installing of build dependencies
#
# <= Lenny = apt-cross
# >  Lenny = xapt
#
# Squeeze needs some backorts to get xapt working, so from now on
# DebWrt will only support wheezy and up.
#
# Link: https://wiki.debian.org/EmdebianToolchain

# note: to speed up setting up: do not install devscripts
# note: a mailservers seems to be installed and started: bad - needs removal

debian/buildenv/emdebian-prepare: debian/buildenv/prepare
	@echo "I: Adding squeeze source incase Emdebiand squeeze is missing packages in wheezy or higher..."
	sudo bash -c "echo \"deb $(call qstrip,$(CONFIG_EMDEBIAN_BUILDENV_REPOSITORY)) $(EMDEBIAN_RELEASE) main\" >> $(DEBIAN_BUILD_DIR)/etc/apt/sources.list"
	sudo bash -c "echo \"deb $(call qstrip,$(CONFIG_DEBIAN_BUILDENV_REPOSITORY)) squeeze main\" >> $(DEBIAN_BUILD_DIR)/etc/apt/sources.list"
	sudo bash -c "echo \"deb-src $(call qstrip,$(CONFIG_DEBIAN_BUILDENV_REPOSITORY)) squeeze main\" >> $(DEBIAN_BUILD_DIR)/etc/apt/sources.list"
	# Add lenny repo, just for apt-cross
	#sudo bash -c "echo \"deb  http://archive.debian.org/debian lenny main\" >> $(DEBIAN_BUILD_DIR)/etc/apt/sources.list"
	#sudo bash -c "echo -e \"Package: *\nPin: release a=lenny\nPin-Priority: 200\" > $(DEBIAN_BUILD_DIR)/etc/apt/preferences"
	sudo chroot $(DEBIAN_BUILD_DIR) apt-get update
	#sudo chroot $(DEBIAN_BUILD_DIR) apt-get -y install apt-cross
	#sudo chroot $(DEBIAN_BUILD_DIR) apt-get -y install libmpfr1ldbl
	sudo chroot $(DEBIAN_BUILD_DIR) apt-get -y install emdebian-archive-keyring xapt dpkg-cross
	sudo chroot $(DEBIAN_BUILD_DIR) bash -c "export LC_ALL=C; apt-get -y --force-yes install build-essential dh-make debootstrap fakeroot zlib1g-dev openssh-client vim pkg-config dpatch libncurses5-dev devscripts subversion automake gcc-multilib g++-multilib quilt"
ifeq ($(TARGET_ARCH),arm)
	sudo chroot $(DEBIAN_BUILD_DIR) bash -c "export LC_ALL=C; apt-get -y --force-yes install libc6-armel-cross libc6-dev-armel-cross binutils-arm-linux-gnueabi gcc-4.3-arm-linux-gnu g++-4.4-arm-linux-gnueabi linux-kernel-headers-armel-cross"
else
	sudo chroot $(DEBIAN_BUILD_DIR) bash -c "export LC_ALL=C; apt-get -y --force-yes install libc6-$(TARGET_ARCH)-cross libc6-dev-$(TARGET_ARCH)-cross binutils-$(TARGET_ARCH)-linux-gnu gcc-4.3-$(TARGET_ARCH)-linux-gnu g++-4.3-$(TARGET_ARCH)-linux-gnu linux-kernel-headers-$(TARGET_ARCH)-cross"
endif
	touch $@

debian/buildenv/qemu: debian/buildenv/qemu-prepare debian/buildenv/qemu-build
	touch $@

debian/buildenv/qemu-clean:
	rm -rf $(DEBIAN_BUILD_DIR)/usr/src/qemu
	rm -f debian/buildenv/qemu-prepare
	rm -f debian/buildenv/qemu-build

debian/buildenv/qemu-prepare:
	$(CHROOT) bash -c "export LC_ALL=C; apt-get -y install libglib2.0-dev"
	mkdir -p $(DEBIAN_BUILD_DIR)/usr/src/qemu
	wget -O $(DEBIAN_BUILD_DIR)/usr/src/qemu/qemu-$(call qstrip,$(CONFIG_DEBIAN_BUILDENV_QEMU_VERSION)).tar.gz http://download.savannah.gnu.org/releases/qemu/qemu-$(call qstrip,$(CONFIG_DEBIAN_BUILDENV_QEMU_VERSION)).tar.gz
	tar xzf $(DEBIAN_BUILD_DIR)/usr/src/qemu/qemu-$(call qstrip,$(CONFIG_DEBIAN_BUILDENV_QEMU_VERSION)).tar.gz -C $(DEBIAN_BUILD_DIR)/usr/src/qemu
	touch $@

debian/buildenv/qemu-build: debian/buildenv/qemu-prepare
	$(CHROOT_USER) bash -c "cd /usr/src/qemu/qemu-$(call qstrip,$(CONFIG_DEBIAN_BUILDENV_QEMU_VERSION)) && ./configure --static --target-list=$(TARGET_ARCH)-linux-user && make"
	$(CHROOT) bash -c "cd /usr/src/qemu/qemu-$(call qstrip,$(CONFIG_DEBIAN_BUILDENV_QEMU_VERSION)) && make install"
	$(CHROOT) cp /usr/local/bin/qemu-$(TARGET_ARCH) /usr/local/bin/qemu-$(TARGET_ARCH)-static
	$(CHROOT_USER) bash -c "cd /usr/src/qemu/qemu-$(call qstrip,$(CONFIG_DEBIAN_BUILDENV_QEMU_VERSION)) && ./configure --target-list=$(TARGET_ARCH)-linux-user && make"
	$(CHROOT) bash -c "cd /usr/src/qemu/qemu-$(call qstrip,$(CONFIG_DEBIAN_BUILDENV_QEMU_VERSION)) && make install"
	touch $@

debian/buildenv/scratchbox-prepare:
	sudo chroot $(DEBIAN_BUILD_DIR) su - $(USER) -c bash -c "mkdir -p $(SB2_ARCH)-lenny"
	sudo chroot $(DEBIAN_BUILD_DIR) su - $(USER) -c bash -c "cd $(SB2_ARCH)-lenny && sb2-init -c /usr/local/bin/qemu-$(SB2_ARCH) MIPS \"$(SB2_ARCH)-linux-gnu-gcc\""
	sudo chroot $(DEBIAN_BUILD_DIR) su - $(USER) -c bash -c "fakeroot /usr/sbin/debootstrap --include=file,iputils-ping,netbase,strace,vim,wget,tcpdump --variant=scratchbox --foreign --arch $(SB2_ARCH) lenny $(SB2_ARCH)-lenny/ $(CONFIG_DEBIAN_BUILDENV_REPOSITORY)"
	sudo chroot $(DEBIAN_BUILD_DIR) su - $(USER) -c bash -c  "cd $(SB2_ARCH)-lenny && sb2 -eR ./debootstrap/debootstrap --second-stage"

debian/buildenv/clean: debian/buildenv/qemu-clean
	# sudo should not be needed if fakechroot would have worked
	sudo rm -rf $(DEBIAN_BUILD_DIR)
	rm -f debian/buildenv/prepare
	rm -f debian/buildenv/qemu-prepare 
	rm -f debian/buildenv/qemu-build

.PHONY: debian/buildenv/clean debian/buildenv

