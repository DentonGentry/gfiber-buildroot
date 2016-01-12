GOOGLE_WIDEVINE_SITE=repo://vendor/google/widevine
GOOGLE_WIDEVINE_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_BCM_COMMON_PLATFORM),"97439")
  WV_TARGET=target_7439
else # 97425 and 97428 chips
  WV_TARGET=target_7425
endif

define GOOGLE_WIDEVINE_INSTALL_TARGET_CMDS
  mkdir -p $(TARGET_DIR)/app/client/
  $(INSTALL) -D -m 0755 $(@D)/$(WV_TARGET)/libWVPlaybackAPI.so $(TARGET_DIR)/app/client/
  $(INSTALL) -D -m 0755 $(@D)/$(WV_TARGET)/libWVStreamControlAPI.so $(TARGET_DIR)/app/client/
endef

define GOOGLE_WIDEVINE_INSTALL_STAGING_CMDS
  mkdir -p $(STAGING_DIR)/usr/local/lib $(STAGING_DIR)/usr/local/include
  $(INSTALL) -D -m 0755 $(@D)/$(WV_TARGET)/libWVPlaybackAPI.so $(STAGING_DIR)/usr/local/lib/
  $(INSTALL) -D -m 0755 $(@D)/$(WV_TARGET)/libWVStreamControlAPI.so $(STAGING_DIR)/usr/local/lib/
  $(INSTALL) -D -m 0644 $(@D)/WVDictionaryKeys.h $(STAGING_DIR)/usr/local/include/
  $(INSTALL) -D -m 0644 $(@D)/WVIPTVClientAPI.h $(STAGING_DIR)/usr/local/include/
  $(INSTALL) -D -m 0644 $(@D)/WVPlaybackAPI.h $(STAGING_DIR)/usr/local/include/
  $(INSTALL) -D -m 0644 $(@D)/WVStatus.h $(STAGING_DIR)/usr/local/include/
  $(INSTALL) -D -m 0644 $(@D)/WVStreamControlAPI.h $(STAGING_DIR)/usr/local/include/
  $(INSTALL) -D -m 0644 $(@D)/WVTypes.h $(STAGING_DIR)/usr/local/include/
  $(INSTALL) -D -m 0644 $(@D)/WVAssetRegistryAPI.h $(STAGING_DIR)/usr/local/include/
  $(INSTALL) -D -m 0644 $(@D)/WVControlSettings.h $(STAGING_DIR)/usr/local/include/
endef

$(eval $(call GENTARGETS))
