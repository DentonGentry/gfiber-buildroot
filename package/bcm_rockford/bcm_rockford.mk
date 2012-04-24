BCM_ROCKFORD_SITE=repo://vendor/broadcom/rockford
BCM_ROCKFORD_DEPENDENCIES=linux bcm_nexus
BCM_ROCKFORD_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/rockford
BCM_ROCKFORD_INSTALL_STAGING=YES


define BCM_ROCKFORD_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/middleware/v3d -f V3DDriver.mk
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/middleware/platform/nexus -f platform_nexus.mk
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/applications/opengles_v3d/v3d/nexus/cube
endef

define BCM_ROCKFORD_INSTALL_STAGING_CMDS
	$(INSTALL) -m 755 -d $(STAGING_DIR)/usr/include/GLES
	$(INSTALL) -m 755 -d $(STAGING_DIR)/usr/include/GLES2
	$(INSTALL) -m 755 -d $(STAGING_DIR)/usr/include/EGL
	$(INSTALL) -m 644 $(@D)/middleware/v3d/interface/khronos/include/GLES/*.h $(STAGING_DIR)/usr/include/GLES/
	$(INSTALL) -m 644 $(@D)/middleware/v3d/interface/khronos/include/GLES2/*.h $(STAGING_DIR)/usr/include/GLES2/
	$(INSTALL) -m 644 $(@D)/middleware/v3d/interface/khronos/include/EGL/*.h $(STAGING_DIR)/usr/include/EGL/
	$(INSTALL) -m 644 -D $(@D)/middleware/v3d/interface/khronos/include/KHR/khrplatform.h $(STAGING_DIR)/usr/include/KHR/khrplatform.h
endef

define BCM_ROCKFORD_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(BCM_NEXUS_DIR)/bin/libv3ddriver.so $(TARGET_DIR)/usr/lib/libv3ddriver.so
	$(INSTALL) -D $(BCM_NEXUS_DIR)/bin/libnxpl.so $(TARGET_DIR)/usr/lib/libnxpl.so
endef

$(eval $(call GENTARGETS,package,bcm_rockford))
