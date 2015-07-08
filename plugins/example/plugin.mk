PLUGIN_$(PLUGIN_NAME)_VERSION:=1.0
PLUGIN_$(PLUGIN_NAME)_UUID:=128A6A00-29FA-11E2-81C1-0800200C9A66

PLUGIN_TARGETS:=test
PLUGIN_TARGETS+=register
PLUGIN_TARGETS+=unregister
PLUGIN_TARGETS+=clean

ifeq ($(CONFIG_$(PLUGIN_NAME)_ENABLE),y)
OPENWRT_PATCH_DIRS += $(PLUGINS_DIR)/${plugin_name}/openwrt
endif

$(call register,${plugin_name},$(PLUGIN_TARGETS))

$(target)/test:
	@echo "Test $(PLUGIN_NAME)"

$(target)/register:
	@echo "Register $(PLUGIN_NAME)"

$(target)/unregister:
	@echo "Unregister $(PLUGIN_NAME)"

$(target)/clean:
	@echo "Clean $(PLUGIN_NAME)"

