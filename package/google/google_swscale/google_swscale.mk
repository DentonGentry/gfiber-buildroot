GOOGLE_SWSCALE_SITE=repo://vendor/google/swscale
GOOGLE_SWSCALE_INSTALL_STAGING = YES

define GOOGLE_SWSCALE_BUILD_CMDS
        $(MAKE) -C $(@D) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -f Makefile.7425
endef

define GOOGLE_SWSCALE_INSTALL_TARGET_CMDS
        mkdir -p $(TARGET_DIR)/app/client/
        $(INSTALL) -D -m 0755 $(@D)/libswscale.so $(TARGET_DIR)/app/client/
        $(STRIPCMD) $(TARGET_DIR)/app/client/libswscale.so
endef

define GOOGLE_SWSCALE_INSTALL_STAGING_CMDS
        $(INSTALL) -D -m 0755 $(@D)/libswscale.so $(STAGING_DIR)/usr/local/lib/
        $(INSTALL) -D -m 0644 $(@D)/swscale.h $(STAGING_DIR)/usr/local/include/
endef

$(eval $(call GENTARGETS_NEW))
