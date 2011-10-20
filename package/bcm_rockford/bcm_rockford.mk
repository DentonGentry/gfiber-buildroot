BCM_ROCKFORD_SITE=repo://vendor/broadcom/rockford
BCM_ROCKFORD_DEPENDENCIES=linux bcm_nexus
BCM_ROCKFORD_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/rockford

include package/bcm_common/bcm_common.mk

define BCM_ROCKFORD_BUILD_CMDS
        $(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/middleware/v3d -f V3DDriver.mk
        $(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/middleware/platform/nexus -f platform_nexus.mk
endef

define BCM_ROCKFORD_INSTALL_TARGET_CMDS
  $(INSTALL) $(BCM_NEXUS_DIR)/bin/libv3ddriver.so $(TARGET_DIR)/usr/lib/modules/libv3ddriver.so
  $(INSTALL) $(BCM_NEXUS_DIR)/bin/libnxpl.so $(TARGET_DIR)/usr/lib/modules/libnxpl.so
endef

$(eval $(call GENTARGETS,package,bcm_rockford))
