BCM_ROCKFORD_SITE=repo://vendor/broadcom/rockford
BCM_ROCKFORD_DEPENDENCIES=linux bcm_nexus
BCM_ROCKFORD_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/rockford
BCM_ROCKFORD_INSTALL_STAGING=YES
BCM_ROCKFORD_DEBUG=B_REFSW_DEBUG=n


ifeq ($(BR2_PACKAGE_BCM_COMMON_PLATFORM),"97425")
define BCM_ROCKFORD_BUILD_PLATFORM_SPECIFIC
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/unittests/nexus/encoder
endef
endif

define BCM_ROCKFORD_BUILD_CMDS
	$(BCM_MAKE_ENV) $(BCM_ROCKFORD_DEBUG) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/middleware/v3d/driver -f V3DDriver.mk
	$(BCM_MAKE_ENV) $(BCM_ROCKFORD_DEBUG) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/middleware/v3d/platform/nexus -f platform_nexus.mk
	$(BCM_MAKE_ENV) $(BCM_ROCKFORD_DEBUG) USE_NXCLIENT=0 NEXUS_MODE=client $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/applications/khronos/v3d/nexus/cube
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/lib/psip
	$(BCM_ROCKFORD_BUILD_PLATFORM_SPECIFIC)
endef

define BCM_ROCKFORD_INSTALL_STAGING_CMDS
	$(INSTALL) -m 755 -d $(STAGING_DIR)/usr/include/GLES
	$(INSTALL) -m 755 -d $(STAGING_DIR)/usr/include/GLES2
	$(INSTALL) -m 755 -d $(STAGING_DIR)/usr/include/EGL
	$(INSTALL) -m 644 $(@D)/middleware/v3d/driver/interface/khronos/include/GLES/*.h $(STAGING_DIR)/usr/include/GLES/
	$(INSTALL) -m 644 $(@D)/middleware/v3d/driver/interface/khronos/include/GLES2/*.h $(STAGING_DIR)/usr/include/GLES2/
	$(INSTALL) -m 644 $(@D)/middleware/v3d/driver/interface/khronos/include/EGL/*.h $(STAGING_DIR)/usr/include/EGL/
	$(INSTALL) -m 644 -D $(@D)/middleware/v3d/driver/interface/khronos/include/KHR/khrplatform.h $(STAGING_DIR)/usr/include/KHR/khrplatform.h
endef

define BCM_ROCKFORD_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(BCM_NEXUS_DIR)/bin/libv3ddriver.so $(TARGET_DIR)/usr/lib/libv3ddriver.so
	$(INSTALL) -D $(BCM_NEXUS_DIR)/bin/libnxpl.so $(TARGET_DIR)/usr/lib/libnxpl.so
endef

$(eval $(call GENTARGETS))
