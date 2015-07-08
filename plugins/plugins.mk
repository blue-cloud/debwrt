# DebWrt - Debian on Embedded devices
#
# Copyright (C) 2011-2012 Johan van Zoomeren <amain@debwrt.net>
#
# Copyright (C) 2012 Elliott Mitchell <ehem+debwrt@m5p.com>
#	2012-10-06  merged OpenWRT patching with DebWRT's patching of OpenWRT
#	2012-10-06  added ability to include Makefile from plugins
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

PLUGINS_AVAILABLE:=$(shell find $(PLUGINS_DIR) \
		 	        -maxdepth 1 \
			        -mindepth 1 \
			        -type d ! \
			        -name '.*' \
			        -printf '%f\n') 
PLUGIN_CHOICE_BEGIN = \
choice\n\
   prompt \"Target Plugin\"\n\
   default PLUGIN_NONE \n\
   help\n\
     Select a target plugin\n\
\nconfig PLUGIN_NONE\n\
  bool\n\
  prompt \"None\"\n\

PLUGIN_CHOICE_END = \
endchoice\n

PLUGIN_CONFIG_LINE = \
config PLUGIN_$${plugin_up}\n\
  bool\n\
  prompt \"$${plugin}\"\n\
  deselect HAS_SUBTARGETS\n\
  deselect DO_CONF_TARGETS\n\


# Register target
#
# $(1): target
# $(2): prerequisite(s)
define register_target
$(1): $(2)
endef

# Register target for plugin
#
# $(1): plugin name
# $(2): debwrt target
#
# Check if CONFIG_PLUGIN_<plugin_name>_ENABLE =  y
# Check if CONFIG_PLUGIN_<plugin_name>_UUID   == PLUGIN_<plugin_name>_UUID
# 
# Register target 
#
# - make plugin specific target a prerequitite of the DebWrt target
# - when DebWrt target is rebuild, first the plugin specic target is rebuild
#
# target: plugin/<pluging_name>/target
#
# or on UUID mismatch:
#
# target: plugin/<plugin_name>/uuid-error
define register_plugin_target
ifeq ($(CONFIG_PLUGIN_$(call upper,$(1))_ENABLE),y)
ifeq ($(call qstrip,$(CONFIG_PLUGIN_$(call upper,$(1))_UUID)),$(PLUGIN_$(call upper,$(1))_UUID))
REGISTERED_TARGETS+=plugin/$(1)/$(2)
ifeq ($(2),plugins/check)
$(call register_target,$(2),plugin/$(call lower,$(1))/uuid-success)
else
$(call register_target,$(2),plugin/$(call lower,$(1))/$(2))
endif
else
$(call register_target,$(2),plugin/$(call lower,$(1))/uuid-error)
endif
endif
endef

# Call-back for plugins: register plugin targets and mandatory plugins/check target
#
# $(1): plugin name
# $(2): list of targets
#
define register
$(eval $(foreach target,$(2) plugins/check,$(eval $(call register_plugin_target,$(1),$(target)))))
endef

# Include a plugin
#
# $(1): plugin name
#
# Define plugin specific variables, before including and
# evaluating plugins/<plugin_name>/plugin.mk.
define include_plugin
ifneq ($(1),)
PLUGIN_NAME:=$(call upper,$(1))
plugin_name:=$(call lower,$(1))
target=plugins/$(call lower,$(1))
include $(PLUGINS_DIR)/$(call lower,$(1))/plugin.mk
endif
endef

# Inlcude plugin.mk for each plugin
$(foreach plugin,$(PLUGINS_AVAILABLE),$(eval $(call include_plugin,$(plugin))))

plugin/%/uuid-success:
ifeq ($(findstring plugins/check,$(MAKECMDGOALS)),plugins/check)
	@echo "Version verified for plugin $(call upper,$*)"
	@echo "  Configured UUID: $(PLUGIN_$(call upper,$*)_UUID) (Config.in)"
	@echo "  Plugin UUID    : $(CONFIG_PLUGIN_$(call upper,$*)_UUID) (plugin.mk)"
else
	@true
endif

plugin/%/uuid-error:
	@echo "Version mismatch for plugin $(call upper,$*)"
	@echo "  Configured UUID: $(PLUGIN_$(call upper,$*)_UUID) (Config.in)"
	@echo "  Plugin UUID    : $(CONFIG_PLUGIN_$(call upper,$*)_UUID) (plugin.mk)"
ifneq ($(findstring plugins/check,$(MAKECMDGOALS)),plugins/check)
	@exit 1
endif

plugins/generate-config:
	@mkdir $(TMP_DIR)
	@/bin/echo -e "$(PLUGIN_CHOICE_BEGIN)" >$(TMP_DIR)/plugins-generated.in
	@for plugin in $(PLUGINS_AVAILABLE); \
	do \
	  plugin_up=$$(echo $${plugin} | tr [a-z] [A-Z]); \
	  echo "Generating config for plugin: $${plugin_up}"; \
	  /bin/echo -e "$(PLUGIN_CONFIG_LINE)" >>$(TMP_DIR)/plugins-generated.in; \
	done
	@/bin/echo -e "$(PLUGIN_CHOICE_END)" >>$(TMP_DIR)/plugins-generated.in
	touch $@

plugins/list:
	@for plugin in $(PLUGINS_AVAILABLE); \
	do \
	   echo $${plugin}; \
	done

plugins/targets/registered:
	@for target in $(REGISTERED_TARGETS); \
	do \
	   echo $${target}; \
	done

plugins/enabled/list:
	@echo $(PLUGINS_ENABLED)
	@for plugin in $(PLUGINS_ENABLED); \
	do \
	   echo $${plugin}; \
	done

plugins/clean:

plugins/check:

test:
	@echo "Test Plugins"

register:
	@echo "Register plugins"


.PHONY: plugins/list \
	plugins/targets/registered \
	plugins/enabled/list \
	plugin/%/uuid-error \
	plugin/%/uuid-success \
	plugins/clean \
	plugins/check

