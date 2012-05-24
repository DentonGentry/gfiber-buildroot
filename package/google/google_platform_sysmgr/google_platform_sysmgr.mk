#############################################################
#
# PLATFORM_SYSMGR (Google Bruno platform sysmgr software)
#
#############################################################
GOOGLE_PLATFORM_SYSMGR_SITE=repo://vendor/google/platform
GOOGLE_PLATFORM_SYSMGR_DEPENDENCIES=linux google_platform_base bcm_nexus
GOOGLE_PLATFORM_SYSMGR_INSTALL_STAGING=YES

ifeq ($(BR2_PACKAGE_BRUNO_DEBUG),y)
define GOOGLE_PLATFORM_SYSMGR_BUILD_TEST_CMDS
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)/sysmgr/build test
endef
define GOOGLE_PLATFORM_SYSMGR_INSTALL_TEST_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/home/test
	$(INSTALL) -D -m 0755 $(@D)/sysmgr/build/test_* $(TARGET_DIR)/home/test
endef
else
define GOOGLE_PLATFORM_SYSMGR_BUILD_TEST_CMDS
endef
define GOOGLE_PLATFORM_SYSMGR_INSTALL_TEST_STAGING_CMDS
endef
define GOOGLE_PLATFORM_SYSMGR_INSTALL_TEST_TARGET_CMDS
endef
endif

	
define GOOGLE_PLATFORM_SYSMGR_BUILD_CMDS
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)/sysmgr/build
	$(GOOGLE_PLATFORM_SYSMGR_BUILD_TEST_CMDS)
endef

define GOOGLE_PLATFORM_SYSMGR_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/sysmgr
	$(INSTALL) -D -m 0644 $(@D)/sysmgr/include/*.h $(STAGING_DIR)/usr/include/sysmgr
	$(INSTALL) -D -m 0644 $(@D)/sysmgr/build/brunoperipheral.pc $(STAGING_DIR)/usr/lib/pkgconfig/brunoperipheral.pc
	$(INSTALL) -D -m 0755 $(@D)/sysmgr/build/libbrunoperipheral.* $(STAGING_DIR)/usr/lib
	$(GOOGLE_PLATFORM_SYSMGR_INSTALL_TEST_STAGING_CMDS)
endef

define GOOGLE_PLATFORM_SYSMGR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/sysmgr/build/libbrunoperipheral.so $(TARGET_DIR)/usr/lib/libbrunoperipheral.so
	$(INSTALL) -D -m 0755 $(@D)/sysmgr/build/sysmgr $(TARGET_DIR)/usr/bin/sysmgr
	$(GOOGLE_PLATFORM_SYSMGR_INSTALL_TEST_TARGET_CMDS)
endef

$(eval $(call GENTARGETS))
