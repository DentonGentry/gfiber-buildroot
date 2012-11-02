GOOGLE_LICENSES_SITE=/dev
GOOGLE_LICENSES_SOURCE=null
GOOGLE_LICENSES_VERSION=HEAD

GOOGLE_LICENSES_DEPENDENCIES = host-google_keystore_client

define GOOGLE_LICENSES_EXTRACT_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/licenses
endef


ifeq ($(BR2_PACKAGE_GOOGLE_LICENSES),y)

ifeq ($(BR2_PACKAGE_BRUNO_PROD),y)
GOOGLE_LICENSES_LICTYPE=playready_prod_license
else
GOOGLE_LICENSES_LICTYPE=playready_dev_license
endif
GOOGLE_KEYSTORE_CLIENT_NEEDS_KEYS += $(GOOGLE_LICENSES_LICTYPE)

endif


define GOOGLE_LICENSES_INSTALL_TARGET_CMDS
	$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,$(GOOGLE_LICENSES_LICTYPE),$(TARGET_DIR)/usr/local/licenses/playready.bin)
endef

$(eval $(call GENTARGETS))
