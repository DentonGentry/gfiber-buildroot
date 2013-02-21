GOOGLE_TS_CHECK_SITE=repo://vendor/google/ts_check
GOOGLE_TS_CHECK_DEPENDENCIES=linux

define GOOGLE_TS_CHECK_BUILD_CMDS
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_TS_CHECK_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/ts_check $(TARGET_DIR)/usr/bin/ts_check
endef

$(eval $(call GENTARGETS))
