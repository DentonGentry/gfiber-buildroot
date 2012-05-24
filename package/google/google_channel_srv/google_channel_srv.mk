GOOGLE_CHANNEL_SRV_SITE=repo://vendor/google/channel_srv
GOOGLE_CHANNEL_SRV_DEPENDENCIES=google_hdhomerun_plugin

define GOOGLE_CHANNEL_SRV_BUILD_CMDS
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_CHANNEL_SRV_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/chsrv \
          $(TARGET_DIR)/app/sage/chsrv
endef

$(eval $(call GENTARGETS))
