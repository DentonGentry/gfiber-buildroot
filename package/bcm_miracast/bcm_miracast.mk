#############################################################
#
# Broadcom's WiFi Display
#
#############################################################

BCM_MIRACAST_SITE=repo://vendor/broadcom/miracast
BCM_MIRACAST_DEPENDENCIES=\
	bcm_bseav bcm_nexus bcm_common bcm_rockford bcm_drivers \
    openssl avahi
BCM_MIRACAST_INSTALL_STAGING=NO
BCM_MIRACAST_INSTALL_TARGET=YES

REV_LOWER = $(shell echo $(BR2_PACKAGE_BCM_COMMON_PLATFORM_REV) | tr A-Z a-z)
INCLUDE_DIR = $(@D)/target/${BR2_PACKAGE_BCM_COMMON_PLATFORM}${REV_LOWER}.mipsel-linux.debug/usr/local/include

define BCM_MIRACAST_CONFIGURE_CMDS
	$(call BCM_COMMON_USE_BUILD_SYSTEM,$(@D))
endef

define BCM_MIRACAST_BUILD_CMDS
	tar -czf $(@D)/broadcom/netapp/netapp/wlan/broadcom/aardvark.tgz -C $(BCM_DRIVERS_DIR) wifi/src
	$(BCM_MAKE_ENV) $(MAKE1) $(BCM_MAKEFLAGS) VERBOSE=y HAS_WIFI_BUILT=y NETAPP_WIFI_WPS=n NETAPP_DATABASE=n AARDVARK_DRIVER_VERSION=wifi WIFI_SRC_PKG=$(@D)/broadcom/netapp/netapp/wlan/broadcom/aardvark.tgz APPLIBS_TOP=$(@D) \
		-C $(@D)/common wfd_libs netapp
endef

define BCM_MIRACAST_INSTALL_TARGET_CMDS
	$(call BCM_COMMON_BUILD_EXTRACT_TARBALL, $(TARGET_DIR))
endef

define BCM_MIRACAST_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/src/apps/nexus_sink_app/libwfd_player.a $(STAGING_DIR)/usr/lib/libwfd_player.a
	$(INSTALL) -D -m 0644 $(@D)/src/apps/nexus_sink_app/libwfd_streamer.a $(STAGING_DIR)/usr/lib/libwfd_streamer.a
endef

$(eval $(call GENTARGETS))
