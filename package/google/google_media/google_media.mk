#############################################################
#
# Google media
#
#############################################################

GOOGLE_MEDIA_SITE_METHOD = null
GOOGLE_MEDIA_INSTALL_TARGET = YES

define GOOGLE_MEDIA_EXTRACT_CMDS
endef

define GOOGLE_MEDIA_INSTALL_TARGET_CMDS
	echo "Installing Google media"
	mkdir -p $(TARGET_DIR)/usr/lib/media
	cp -rp package/google/google_media/media/. $(TARGET_DIR)/usr/lib/media
endef

$(eval $(call GENTARGETS))
