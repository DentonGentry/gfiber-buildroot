GOOGLE_LICENSES_SITE_METHOD=null

GOOGLE_LICENSES_DEPENDENCIES = bcm_bseav

define GOOGLE_LICENSES_EXTRACT_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/licenses
endef


ifeq ($(BR2_PACKAGE_GOOGLE_LICENSES),y)

ifeq ($(BR2_TARGET_GENERIC_PLATFORM_NAME),"gfibertv")
  GOOGLE_PLAYREADY_LIC_NAME=playready_2_5_gfhd100_license
endif
ifeq ($(BR2_TARGET_GENERIC_PLATFORM_NAME),"gftv200")
  GOOGLE_PLAYREADY_LIC_NAME=playready_2_5_gfhd200_license
endif
TARGET_FILE=$(TARGET_DIR)/usr/local/licenses/playready.bin

endif


define GOOGLE_LICENSES_INSTALL_TARGET_CMDS
	[ -f $(TARGET_FILE) ] && chmod 0600 $(TARGET_FILE); \
	cp $(BCM_BSEAV_DIR)/gfiber/$(GOOGLE_PLAYREADY_LIC_NAME) $(TARGET_FILE) && \
	chmod 0400 $(TARGET_FILE)
endef

$(eval $(call GENTARGETS))
