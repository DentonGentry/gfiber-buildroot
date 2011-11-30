#############################################################
#
# directfb
#
#############################################################
DIRECTFB_VERSION_MAJOR = 1.4
DIRECTFB_VERSION = $(DIRECTFB_VERSION_MAJOR).13
DIRECTFB_SITE = http://www.directfb.org/downloads/Core/DirectFB-$(DIRECTFB_VERSION_MAJOR)
DIRECTFB_SOURCE = DirectFB-$(DIRECTFB_VERSION).tar.gz
DIRECTFB_DEPENDENCIES = bcm_apps
DIRECTFB_INSTALL_STAGING = YES
DIRECTFB_INSTALL_TARGET = YES

include package/bcm_common/bcm_common.mk

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
	echo no-cursor >> $(TARGET_DIR)/usr/local/etc/directfbrc
endef


$(eval $(call GENTARGETS,package,directfb))

