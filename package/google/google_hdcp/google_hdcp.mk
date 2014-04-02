GOOGLE_HDCP_SITE=repo://vendor/google/hdcp
GOOGLE_HDCP_DEPENDENCIES=bcm_nexus host-pkg-config
GOOGLE_HDCP_INSTALL_STAGING=YES

define GOOGLE_HDCP_BUILD_CMDS
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_HDCP_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/hdcp.h $(STAGING_DIR)/usr/include/hdcp/hdcp.h
	$(INSTALL) -D -m 0644 $(@D)/brunohdcp.h $(STAGING_DIR)/usr/include/hdcp/brunohdcp.h
	$(INSTALL) -D -m 0644 $(@D)/libgoogle_hdcp.so $(STAGING_DIR)/usr/lib/libgoogle_hdcp.so
endef

define GOOGLE_HDCP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libgoogle_hdcp.so $(TARGET_DIR)/usr/lib/libgoogle_hdcp.so
endef

$(eval $(call GENTARGETS))
