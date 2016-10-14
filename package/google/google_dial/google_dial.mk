GOOGLE_DIAL_SITE=repo://vendor/opensource/dial

define GOOGLE_DIAL_BUILD_CMDS
	$(MAKE) TARGET=${TARGET_CROSS} -C $(@D)/server dialserver
endef

define GOOGLE_DIAL_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D package/google/google_dial/S98dialserver $(TARGET_DIR)/etc/init.d/S98dialserver
	$(INSTALL) -m 0755 -D $(@D)/server/dialserver $(TARGET_DIR)/app/client/dialserver
	$(INSTALL) -m 0755 -D package/google/google_dial/rundialserver $(TARGET_DIR)/app/client/rundialserver
endef

$(eval $(call GENTARGETS))
