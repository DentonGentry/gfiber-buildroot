MV_APP_SITE=repo://vendor/marvell/application
MV_APP_DEPENDENCIES=linux sqlite

define MV_APP_CLEAN_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CROSS_COMPILE=$(TARGET_CROSS) -C $(@D) clean
endef

define MV_APP_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CROSS_COMPILE=$(TARGET_CROSS) -C $(@D)
endef

define MV_APP_INSTALL_TARGET_CMDS
	cp -fr $(@D)/build/bin/* $(TARGET_DIR)/usr/bin/. && \
	chmod 6750 $(TARGET_DIR)/usr/bin/clish && \
	cp -fr $(@D)/build/lib/* $(TARGET_DIR)/usr/lib/. && \
	mkdir -p $(TARGET_DIR)/etc/xml_commands && \
	cp -fr $(@D)/main/xml_commands/* $(TARGET_DIR)/etc/xml_commands/. && \
	if [ -e "$(@D)/tools/omci_tool" ]; then \
		cp -f  $(@D)/tools/omci_tool $(TARGET_DIR)/usr/bin/.; \
	fi
endef

$(eval $(call GENTARGETS))
