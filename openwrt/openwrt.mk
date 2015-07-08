# DebWrt - Debian on Embedded devices
#
# Copyright (C) 2010 Johan van Zoomeren <amain@debwrt.net>
#
# Copyright (C) 2012 Elliott Mitchell <ehem+debwrt@m5p.com>
#	2012-09-27  fixes to files-copy, rework checkout/update
#	2012-09-28  complete rewrite of patch/unpatch targets, new capabilities
#	2012-09-30  tweaking of patch/unpatch, now handles differing dir levels
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

OPENWRT_PATCHES_DIR=$(TOPDIR)/openwrt/patches
OPENWRT_PATCH_DIRS:= "$(OPENWRT_PATCHES_DIR)/all" \
	"$(OPENWRT_PATCHES_DIR)/$(OPENWRT_BRANCH)"

get_patches = \
	if [ ! -d "$(OPENWRT_BUILD_DIR)" ]; then exit 1; fi ; \
	rev=$(call get_svn_revision,$(OPENWRT_BUILD_DIR)) ; \
	find \
	  $(OPENWRT_PATCH_DIRS) \
	  -name .svn -prune -o \! -type d -printf %f/%p\\n | \
	gawk -F / '\
	  BEGIN { OFS=FS } \
	  match($$1, "^([[:digit:]]+)((-$(OPENWRT_BRANCH))|(-all))?(-([[:digit:]]*):([[:digit:]]*))?(_[^/]*)", revs) \
	    { if(revs[6] <= '$${rev}' && (!length(revs[7]) || revs[7] >= '$${rev}')) \
	      { $$1=revs[1] revs[8]; print } \
	    }' | \
	sort $(1) | sed -e's/^[^/]\+\///'

do_patches = \
	if [ ! -d "$(OPENWRT_BUILD_DIR)" ]; then exit 1; fi ; \
	$(call get_patches,$(1)) | while read patch ; \
	do \
		patchi=$$(echo $${patch} | sed -e's!$(TOPDIR)/!!') ; \
		if ! patch -b -d "$(OPENWRT_BUILD_DIR)" -p1 $(2) < "$${patch}" ; \
		then \
			echo ">> fail: $${patchi}" > /dev/stderr ; \
			$(if $(FORCE_PATCH),retval=1,exit 1) ; \
		else \
			echo ">> success: $${patchi}" ; \
		fi ; \
	done

openwrt/all: openwrt/build
	$(MAKE) -C $(TOPDIR) openwrt/deliver
	touch $@

openwrt/build: openwrt/prepare
ifeq ("$(origin V)", "command line")
	$(SCRIPT_CLEAN_EXEC) $(MAKE) -C $(OPENWRT_BUILD_DIR) $(CONFIG_OPENWRT_MAKE_OPTIONS) V=$(V)
else
	$(SCRIPT_CLEAN_EXEC) $(MAKE) -C $(OPENWRT_BUILD_DIR) $(CONFIG_OPENWRT_MAKE_OPTIONS)
endif
	touch $@

openwrt/download:
ifeq ("$(origin V)", "command line")
	$(SCRIPT_CLEAN_EXEC) $(MAKE) -C $(OPENWRT_BUILD_DIR) download V=$(V)
else
	$(SCRIPT_CLEAN_EXEC) $(MAKE) -C $(OPENWRT_BUILD_DIR) download
endif
	touch $@

openwrt/prepare: \
  openwrt/checkout \
  openwrt/patch \
  openwrt/files-copy \
  openwrt/merge-config \
  openwrt/download-link
	touch $@

openwrt/merge-config: .config $(OPENWRT_BUILD_DIR)/.config openwrt/checkout openwrt/patch
	mkdir -p $(TMP_DIR)
	# Copy default OpenWrt settings
	cp $(CONFIG_DIR)/openwrt.defconfig $(TMP_DIR)/.config_openwrt
	# Merge default OpenWrt settings with DebWrt menu config settings
	grep -v -e CONFIG_TARGET_BOARD .config >> $(TMP_DIR)/.config_openwrt
	# Merge default and menu settings with possibly altered settings in make menuconfig in OpenWrt
	# note: settings manually made in OpenWrt menu config will be included!
	touch $(OPENWRT_BUILD_DIR)/.config
	cp $(OPENWRT_BUILD_DIR)/.config $(OPENWRT_BUILD_DIR)/.config.org
	$(SCRIPT_KCONFIG) + $(OPENWRT_BUILD_DIR)/.config.org $(TMP_DIR)/.config_openwrt > $(OPENWRT_BUILD_DIR)/.config
	# Filter out config options unknown to OpenWrt (e.g. pure kernel known options) / clean up OpenWrt config
	$(SCRIPT_CLEAN_EXEC) $(MAKE) -C $(OPENWRT_BUILD_DIR) defconfig
	# Save .config to OpenWrt build-dir. During the OpenWrt build the .config kernel options are
	# merged with the OpenWrt's default kernel options for the target. In this phase any DebWrt/OpenWrt
	# specific options in the .config file are filtered out. See include/kernel-defaults.mk from OpenWrt.
	cp .config $(OPENWRT_BUILD_DIR)/.config.debwrt
	touch $@

$(OPENWRT_BUILD_DIR)/.config: openwrt/checkout
	[ ! -f $@ ] && touch $(OPENWRT_BUILD_DIR)/.config

openwrt/download-link: openwrt/checkout
ifneq ($(OPENWRT_DOWNLOAD_DIR),)
	cd $(OPENWRT_BUILD_DIR) && if [ -d $(OPENWRT_DOWNLOAD_DIR) -a ! -e dl ]; then ln -snf $(OPENWRT_DOWNLOAD_DIR) dl; fi
endif
	touch $@

openwrt/patch/show: openwrt/checkout
	@$(call get_patches) | while read patch ;\
	do \
	   echo $${patch}; \
	done

openwrt/patch/force:
	rm -f $(TOPDIR)/openwrt/patch ; \
	$(MAKE) -C $(TOPDIR) openwrt/patch FORCE_PATCH=1 ; \

openwrt/patch: openwrt/checkout
	@$(call do_patches,,-N)
	rm -f openwrt/unpatch 
	touch $@

openwrt/unpatch/show: openwrt/checkout
	@$(call get_patches,-r) | while read patch ;\
	do \
	   echo $${patch}; \
	done
openwrt/unpatch/force:
	rm -f $(TOPDIR)/openwrt/unpatch ; \
	$(MAKE) -C $(TOPDIR) openwrt/unpatch FORCE_PATCH=1 ; \

openwrt/unpatch:
	@if [ ! -f $(TOPDIR)/openwrt/patch ]; then \
	   echo "E: can't unpatch if patches have not previously been applied"; \
	   exit 1; \
	fi
	@$(call do_patches,-r,-R)
	rm -f openwrt/patch
	touch $@

openwrt/files-copy: openwrt/patch
	tar -C $(FILES_DIR_OPENWRT) --exclude-vcs -cpf - . | \
	  tar -C $(OPENWRT_BUILD_DIR) -xpf - && \
	touch $@

ifeq ($(OPENWRT_BRANCH),trunk)
OPENWRT_SUBVERSION:=$(call qstrip,$(CONFIG_OPENWRT_SVN_REPO_URL))/trunk/
else ifeq ($(OPENWRT_TAG),)
OPENWRT_SUBVERSION:=$(call qstrip,$(CONFIG_OPENWRT_SVN_REPO_URL))/branches/$(OPENWRT_BRANCH)/
else
OPENWRT_SUBVERSION:=$(call qstrip,$(CONFIG_OPENWRT_SVN_REPO_URL))/tags/$(OPENWRT_TAG)
endif

$(OPENWRT_BUILD_DIR)/.debwrt.checkout.stamp:
openwrt/checkout: $(OPENWRT_BUILD_DIR)/.debwrt.checkout.stamp
	if [ ! -f $(TOPDIR)/.config ]; then echo "Please type menuconfig first"; exit 1; fi
	mkdir -p $(OPENWRT_BUILD_DIR)
	svn co -r $(OPENWRT_REVISION) $(OPENWRT_SUBVERSION) $(OPENWRT_BUILD_DIR)
	touch $(OPENWRT_BUILD_DIR)/.debwrt.checkout.stamp
	touch $@

openwrt/update: openwrt/checkout
	svn up -r $(OPENWRT_REVISION) $(OPENWRT_BUILD_DIR)

openwrt/menuconfig: openwrt/prepare
	$(SCRIPT_CLEAN_EXEC) $(MAKE) -C $(OPENWRT_BUILD_DIR) menuconfig

# Tune kernel configuration
openwrt/kernel_menuconfig: openwrt/prepare
	$(SCRIPT_CLEAN_EXEC) $(MAKE) -C $(OPENWRT_BUILD_DIR) kernel_menuconfig
	rm -f openwrt/build

openwrt/wrtclean:
	-$(SCRIPT_CLEAN_EXEC) $(MAKE) -C $(OPENWRT_BUILD_DIR) clean V=$(V)

openwrt/dirclean:
	-$(SCRIPT_CLEAN_EXEC) $(MAKE) -C $(OPENWRT_BUILD_DIR) dirclean V=$(V)

openwrt/distclean:
	-$(SCRIPT_CLEAN_EXEC) $(MAKE) -C $(OPENWRT_BUILD_DIR) distclean V=$(V)

openwrt/clean:
	rm -rf $(OPENWRT_BUILD_DIR)
	rm -f openwrt/checkout
	rm -f openwrt/patch
	rm -f openwrt/files-copy

.PHONY: openwrt/patch/force \
	openwrt/unpatch/force \
	openwrt/clean \

