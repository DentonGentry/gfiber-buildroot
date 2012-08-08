HUMAX_MISC_SITE=repo://vendor/humax/misc
HUMAX_MISC_INSTALL_STAGING=YES
HUMAX_MISC_INSTALL_TARGET=YES

HUMAX_MISC_STAGING_PATH=usr/lib/humax

define HUMAX_MISC_BUILD_CMDS
	TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)/libupgrade
endef

define HUMAX_MISC_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/$(HUMAX_MISC_STAGING_PATH) && \
	$(INSTALL) -m 0755 $(@D)/makehdf $(STAGING_DIR)/$(HUMAX_MISC_STAGING_PATH)
	$(INSTALL) -m 0755 $(@D)/libupgrade/libhmxupgrade.a $(STAGING_DIR)/usr/lib/libhmxupgrade.a
	$(INSTALL) -m 0644 $(@D)/libupgrade/hmx_upgrade_nvram.h $(STAGING_DIR)/usr/include/humax
endef

$(eval $(call GENTARGETS))
