#############################################################
#
# directfb
#
#############################################################
DIRECTFB_VERSION_MAJOR = 1.4
DIRECTFB_VERSION = $(DIRECTFB_VERSION_MAJOR).13
DIRECTFB_SITE = http://www.directfb.org/downloads/Core/DirectFB-$(DIRECTFB_VERSION_MAJOR)
DIRECTFB_SOURCE = DirectFB-$(DIRECTFB_VERSION).tar.gz
# we're using bcm_apps to provide directfb, but to avoid circular
# dependencies, we won't explicitly mention it. the only dependency
# on bcm_apps is that the source is extracted and patched
directfb-build: bcm_apps-patch
DIRECTFB_INSTALL_STAGING = YES
DIRECTFB_INSTALL_TARGET = YES


define DIRECTFB_REMOVE_CONFIG
	rm -f $(TARGET_DIR)/usr/local/bin/directfb/$(DIRECTFB_VERSION_MAJOR)/directfb-config
endef

ifeq ($(BR2_PACKAGE_BRUNO),y)
DIRECTFB_POST_INSTALL_TARGET_HOOKS += DIRECTFB_REMOVE_CONFIG
endif

define DIRECTFB_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE1) $(BCM_MAKEFLAGS) -C $(BCM_APPS_DIR)/common directfb
endef

define DIRECTFB_BUILD_EXTRACT_TARBALL
	rm -f $(BCM_APPS_DIR)/target/97425*.mipsel-linux*$(BCM_APPS_BUILD_TYPE).*tgz
	$(BCM_MAKE_ENV) $(MAKE1) $(BCM_MAKEFLAGS) -C $(BCM_APPS_DIR)/common bundle
	$(TAR) -xf $(BCM_APPS_DIR)/target/97425*.mipsel-linux*$(BCM_APPS_BUILD_TYPE).*tgz -C $(1)
endef

define DIRECTFB_INSTALL_STAGING_CMDS
	$(call DIRECTFB_BUILD_EXTRACT_TARBALL,$(STAGING_DIR))
endef

define DIRECTFB_INSTALL_TARGET_CMDS
	$(call DIRECTFB_BUILD_EXTRACT_TARBALL,$(TARGET_DIR))
endef


$(eval $(call GENTARGETS))

