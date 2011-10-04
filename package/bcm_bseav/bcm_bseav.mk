BCM_BSEAV_SITE=repo://vendor/broadcom/BSEAV
BCM_BSEAV_DEPENDENCIES=linux bcm_nexus
BCM_BSEAV_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/BSEAV

include package/bcm_common/bcm_common.mk

#define BCM_BSEAV_BUILD_CMDS
#	 $(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS)  -C $(@D)/app/brutus/build install
#endef

#define BCM_BSEAV_INSTALL_TARGET_CMDS
#	mkdir -p $(TARGET_DIR)/opt/brcm
#	$(TAR) -xf $(@D)/bin/refsw*.tgz -C $(TARGET_DIR)/opt/brcm
#endef

$(eval $(call GENTARGETS,package,bcm_bseav))
