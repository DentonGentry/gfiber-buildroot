GOOGLE_PULLREADER_SITE=repo://vendor/sagetv/pullreader
GOOGLE_PULLREADER_DEPENDENCIES=google_ffmpeg
GOOGLE_PULLREADER_INSTALL_STAGING = YES

define GOOGLE_PULLREADER_BUILD_CMDS
        PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
        PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
        PKG_CONFIG_PATH="$(STAGING_DIR)/usr/local/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
        $(MAKE) -C $(@D)/lib CC="$(TARGET_CC)" LD="$(TARGET_LD)" -f Makefile.7425
endef

define GOOGLE_PULLREADER_INSTALL_TARGET_CMDS
        mkdir -p $(TARGET_DIR)/app/client/
        $(INSTALL) -D -m 0755 $(@D)/lib/libPullreader.so $(TARGET_DIR)/app/client/
        $(STRIPCMD) $(TARGET_DIR)/app/client/libPullreader.so
endef

define GOOGLE_PULLREADER_INSTALL_STAGING_CMDS
        $(INSTALL) -D -m 0755 $(@D)/lib/libPullreader.so $(STAGING_DIR)/usr/local/lib/
        $(INSTALL) -D -m 0644 $(@D)/lib/pullreader.h $(STAGING_DIR)/usr/local/include/
endef

$(eval $(call GENTARGETS))
