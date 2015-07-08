# DebWrt - Debian on Embedded devices
#
# Copyright (C) 2010 Johan van Zoomeren
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

TOPDIR:=$(CURDIR)
MCONF_DIR=$(TOPDIR)/config/mconf
CONF:=$(TOPDIR)/config/mconf/conf
MCONF:=$(TOPDIR)/config/mconf/mconf

all: config/mconf/mconf

config/mconf/mconf:
	@$(MAKE) -s -C $(MCONF_DIR) all

config/mconf/conf:
	@$(MAKE) -s -C $(MCONF_DIR) conf

# Create new config-target.in from OpenWrt's targets config generated file
# note: include the select <target> lines, exlcude all other selects
config/target: openwrt/menuconfig
	LC_ALL=C cat $(OPENWRT_BUILD_DIR)/tmp/.config-target.in \
	  | awk \
	    '/select\W+[[:lower:]]/ { \
	       print $0 \
	     } \
	     \
	     /select.*HAS_SUBTARGETS/ { \
	       print $0 \
	     } \
	     ! /select/ { \
	       print $0 \
	     }' \
	     | sed \
                -e 's/prompt "Target System"/prompt "Target System" if DO_CONF_TARGETS/' \
                -e 's/prompt "Target Profile"/prompt "Target Profile" if DO_CONF_TARGETS/' \
	     >$(TOPDIR)/config/target.in
	cat $(OPENWRT_BUILD_DIR)/target/Config.in \
	  | grep -v "source " \
	  >$(TOPDIR)/config/archs.in

config/clean:
	$(MAKE) -C $(MCONF_DIR) clean

.config:
	@echo "Please run make menuconfig to create a configuration. Then run make again. Type make help to get a list of available DebWrt make commands"
	@exit 1

# stop our value from leaking into the config tool, which can be problematic
config defconfig oldconfig menuconfig: TARGET_ARCH=

config: plugins/generate-config config/mconf/conf FORCE
	$(CONF) Config.in
	@echo "Type make help to get a list of available DebWrt make commands"

defconfig: plugins/generate-config config/mconf/conf FORCE
	touch .config
	$(CONF) -D .config Config.in
	@echo "Type make help to get a list of available DebWrt make commands"

oldconfig: plugins/generate-config config/mconf/conf FORCE
	$(CONF) -o Config.in
	@echo "Type make help to get a list of available DebWrt make commands"

menuconfig: plugins/generate-config config/mconf/mconf FORCE
	$(MCONF) Config.in
	@echo "Type make help to get a list of available DebWrt make commands"

.PHONY: config/clean

