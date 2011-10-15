BCM_NEXUS_SITE=repo://vendor/broadcom/nexus
# TODO (by kedong) The dependency on bruno will be moved to board level
# config in buildroot.
BCM_NEXUS_DEPENDENCIES=linux bruno bcm_magnum bcm_bseav host-pkg-config
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
	sed -i"" -e "s@$(@D)@/$(BCM_NEXUS_STAGING_PATH)@g" -e "s@std=c89@std=c99@g" $(@D)/bin/nexus.pc
	$(INSTALL) -D $(@D)/bin/nexus.pc $(STAGING_DIR)/usr/lib/pkgconfig/nexus.pc
endef

define BCM_NEXUS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/$(BCM_NEXUS_TARGET_PATH)/bin
	cp $(@D)/bin/* $(TARGET_DIR)/$(BCM_NEXUS_TARGET_PATH)/bin
	rm $(TARGET_DIR)/$(BCM_NEXUS_TARGET_PATH)/bin/nexus.pc
endef

$(eval $(call GENTARGETS,package,bcm_nexus))
