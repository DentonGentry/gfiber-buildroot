#############################################################
#
# PLATFORM_BASE (Google Bruno platform base software)
#
#############################################################
GOOGLE_PLATFORM_BASE_SITE=repo://vendor/google/platform
GOOGLE_PLATFORM_BASE_DEPENDENCIES=linux
GOOGLE_PLATFORM_BASE_INSTALL_STAGING=YES

define GOOGLE_PLATFORM_BASE_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)/base/build
endef

define GOOGLE_PLATFORM_BASE_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/base
	cp -rf $(@D)/base/src/*.h $(STAGING_DIR)/usr/include/base
	$(INSTALL) -D -m 0644 $(@D)/base/build/brunobase.pc $(STAGING_DIR)/usr/lib/pkgconfig/brunobase.pc
	$(INSTALL) -D -m 0755 $(@D)/base/build/libbrunobase.* $(STAGING_DIR)/usr/lib
endef

define GOOGLE_PLATFORM_BASE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/base/build/libbrunobase.so $(TARGET_DIR)/usr/lib/libbrunobase.so
endef

$(eval $(call GENTARGETS))
