BCM_MAGNUM_SITE=repo://vendor/broadcom/magnum
BCM_MAGNUM_DEPENDENCIES=linux
BCM_MAGNUM_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/magnum

BCM_MAGNUM_STAGING_PATH=usr/lib/magnum


define BCM_MAGNUM_INSTALL_STAGING_CMDS
	ln -sf $(@D) $(STAGING_DIR)/$(BCM_MAGNUM_STAGING_PATH)
endef

$(eval $(call GENTARGETS))
