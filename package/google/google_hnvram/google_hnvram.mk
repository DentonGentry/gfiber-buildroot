#############################################################
#
# hnvram (NVRAM manipulation)
#
#############################################################
GOOGLE_HNVRAM_SITE=repo://vendor/google/platform
GOOGLE_HNVRAM_DEPENDENCIES=humax_misc
GOOGLE_HNVRAM_INSTALL_STAGING=YES
GOOGLE_HNVRAM_INSTALL_TARGET=YES

define GOOGLE_HNVRAM_BUILD_CMDS
	TARGET=$(TARGET_CROSS) HUMAX_UPGRADE_DIR=$(HUMAX_MISC_DIR)/libupgrade $(MAKE) -C $(@D)/bruno/hnvram
endef

define GOOGLE_HNVRAM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bruno/hnvram/hnvram $(TARGET_DIR)/usr/bin/
endef

$(eval $(call GENTARGETS))
