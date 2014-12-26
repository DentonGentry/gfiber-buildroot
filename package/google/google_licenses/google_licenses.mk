GOOGLE_LICENSES_SITE_METHOD=null

GOOGLE_LICENSES_DEPENDENCIES = host-google_keystore_client

define GOOGLE_LICENSES_EXTRACT_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/licenses
endef


ifeq ($(BR2_PACKAGE_GOOGLE_LICENSES),y)

ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
  ifeq ($(BR2_TARGET_GENERIC_PLATFORM_NAME),"gfibertv")
    GOOGLE_LICENSES_LICTYPE=playready2_prod_license
  endif
  ifeq ($(BR2_TARGET_GENERIC_PLATFORM_NAME),"gftv200")
    GOOGLE_LICENSES_LICTYPE=playready2_gfhd200_prod_license
  endif
else
  ifeq ($(BR2_TARGET_GENERIC_PLATFORM_NAME),"gfibertv")
    GOOGLE_LICENSES_LICTYPE=playready2_dev_license
  endif
  ifeq ($(BR2_TARGET_GENERIC_PLATFORM_NAME),"gftv200")
    GOOGLE_LICENSES_LICTYPE=playready2_gfhd200_dev_license
  endif
endif
GOOGLE_KEYSTORE_CLIENT_NEEDS_KEYS += $(GOOGLE_LICENSES_LICTYPE)

endif


define GOOGLE_LICENSES_INSTALL_TARGET_CMDS
	$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,$(GOOGLE_LICENSES_LICTYPE),$(TARGET_DIR)/usr/local/licenses/playready.bin)
endef

$(eval $(call GENTARGETS))
