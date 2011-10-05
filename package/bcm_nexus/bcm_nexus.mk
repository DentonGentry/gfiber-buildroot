BCM_NEXUS_SITE=repo://vendor/broadcom/nexus
BCM_NEXUS_DEPENDENCIES=linux bcm_magnum bcm_bseav
BCM_NEXUS_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/nexus
BCM_NEXUS_INSTALL_STAGING=YES
BCM_NEXUS_INSTALL_TARGET=YES

BCM_NEXUS_STAGING_PATH=usr/lib/nexus
BCM_NEXUS_TARGET_PATH=usr/lib/nexus

include package/bcm_common/bcm_common.mk

define BCM_NEXUS_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/build all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/examples pkg-config
endef


define BCM_NEXUS_INSTALL_STAGING_CMDS
	ln -sf $(@D) $(STAGING_DIR)/$(BCM_NEXUS_STAGING_PATH)
	cat $(@D)/bin/nexus.pc | \
	sed "s@$(@D)@/$(BCM_NEXUS_STAGING_PATH)@g" | \
	sed "s@std=c89@std=c99@g" > $(STAGING_DIR)/usr/lib/pkgconfig/nexus.pc
endef

define BCM_NEXUS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/$(BCM_NEXUS_TARGET_PATH)/bin
	cp $(@D)/bin/* $(TARGET_DIR)/$(BCM_NEXUS_TARGET_PATH)/bin
	rm $(TARGET_DIR)/$(BCM_NEXUS_TARGET_PATH)/bin/nexus.pc
endef

$(eval $(call GENTARGETS,package,bcm_nexus))
