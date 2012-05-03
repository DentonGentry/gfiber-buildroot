GOOGLE_WIDEVINE_SITE=repo://vendor/google/widevine
GOOGLE_WIDEVINE_INSTALL_STAGING = YES

define GOOGLE_WIDEVINE_INSTALL_TARGET_CMDS
        mkdir -p $(TARGET_DIR)/app/client/
        $(INSTALL) -D -m 0755 $(@D)/libWVPlaybackAPI.so $(TARGET_DIR)/app/client/
        $(INSTALL) -D -m 0755 $(@D)/libWVStreamControlAPI.so $(TARGET_DIR)/app/client/
endef

define GOOGLE_WIDEVINE_INSTALL_STAGING_CMDS
        $(INSTALL) -D -m 0755 $(@D)/libWVPlaybackAPI.so $(STAGING_DIR)/usr/local/lib/
        $(INSTALL) -D -m 0755 $(@D)/libWVStreamControlAPI.so $(STAGING_DIR)/usr/local/lib/
        $(INSTALL) -D -m 0644 $(@D)/WVDictionaryKeys.h $(STAGING_DIR)/usr/local/include/
        $(INSTALL) -D -m 0644 $(@D)/WVIPTVClientAPI.h $(STAGING_DIR)/usr/local/include/
        $(INSTALL) -D -m 0644 $(@D)/WVPlaybackAPI.h $(STAGING_DIR)/usr/local/include/
        $(INSTALL) -D -m 0644 $(@D)/WVStatus.h $(STAGING_DIR)/usr/local/include/
        $(INSTALL) -D -m 0644 $(@D)/WVStreamControlAPI.h $(STAGING_DIR)/usr/local/include/
        $(INSTALL) -D -m 0644 $(@D)/WVTypes.h $(STAGING_DIR)/usr/local/include/
        $(INSTALL) -D -m 0644 $(@D)/WVAssetRegistryAPI.h $(STAGING_DIR)/usr/local/include/
endef

$(eval $(call GENTARGETS_NEW))
