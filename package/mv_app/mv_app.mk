MV_APP_SITE=repo://vendor/marvell/application
MV_APP_DEPENDENCIES=linux sqlite

define MV_APP_CLEAN_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CROSS_COMPILE=$(TARGET_CROSS) -C $(@D) clean
endef

define MV_APP_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) CROSS_COMPILE=$(TARGET_CROSS) \
		PON_TYPE=$(BR2_PACKAGE_MV_APP_PON_TYPE) -C $(@D)
endef

define MV_APP_INSTALL_TARGET_CMDS
	cp -fr $(@D)/build/bin/* $(TARGET_DIR)/usr/bin/
	cp -fr $(@D)/build/lib/* $(TARGET_DIR)/usr/lib/
	cp -fr $(@D)/build/ipc/* $(TARGET_DIR)/usr/lib/
	mkdir -p $(TARGET_DIR)/etc/xml_commands
	cp -fr $(@D)/build/xml/xml_commands/* $(TARGET_DIR)/etc/xml_commands/
	if [ -e "$(@D)/tools/omci_tool" ]; then \
		cp -f  $(@D)/tools/omci_tool $(TARGET_DIR)/usr/bin/; \
	fi
	mkdir -p $(TARGET_DIR)/etc/xml_params
	cp -fpP package/mv_app/xml_params/* $(TARGET_DIR)/etc/xml_params/
endef

$(eval $(call GENTARGETS))
