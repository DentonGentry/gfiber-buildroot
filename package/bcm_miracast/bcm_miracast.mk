#############################################################
#
# Broadcom's WiFi Display
#
#############################################################

BCM_MIRACAST_SITE=repo://vendor/broadcom/miracast
BCM_MIRACAST_DEPENDENCIES=\
	bcm_bseav bcm_nexus bcm_common bcm_rockford bcm_drivers \
    openssl avahi google_miniclient
BCM_MIRACAST_INSTALL_STAGING=NO
BCM_MIRACAST_INSTALL_TARGET=YES

REV_LOWER = $(shell echo $(BR2_PACKAGE_BCM_COMMON_PLATFORM_REV) | tr A-Z a-z)
INCLUDE_DIR = $(@D)/target/${BR2_PACKAGE_BCM_COMMON_PLATFORM}${REV_LOWER}.mipsel-linux.${BCM_COMMON_BUILD_TYPE}/usr/local/include

define BCM_MIRACAST_CONFIGURE_CMDS
	$(call BCM_COMMON_USE_BUILD_SYSTEM,$(@D))
endef

define BCM_MIRACAST_BUILD_CMDS
	tar -czf $(@D)/broadcom/netapp/netapp/wlan/broadcom/aardvark.tgz -C $(BCM_DRIVERS_DIR) wifi/src
	$(BCM_MAKE_ENV) NEXUS_MODE=client $(MAKE1) $(BCM_MAKEFLAGS) \
        VERBOSE=y \
        HAS_WIFI_BUILT=y \
        NETAPP_USB=n \
        NETAPP_IPERF=n \
        NETAPP_WIFI_WPS=n \
        NETAPP_SSDP=n \
        NETAPP_ZEROCONF=n \
        NETAPP_VOICE_RECOGNITION=n \
        NETAPP_DATABASE=n \
        AARDVARK_DRIVER_VERSION=wifi \
        SW7425_5525=1 \
        WIFI_SRC_PKG=$(@D)/broadcom/netapp/netapp/wlan/broadcom/aardvark.tgz \
        APPLIBS_TOP=$(@D) \
		-C $(@D)/common netapp
endef

define BCM_MIRACAST_INSTALL_TARGET_CMDS
	$(call BCM_COMMON_BUILD_EXTRACT_TARBALL, $(TARGET_DIR))
	$(INSTALL) -m 0755 -D package/google/google_miracast/S98miracast $(TARGET_DIR)/etc/init.d/S98miracast
	$(INSTALL) -D -m 0755 package/google/google_miracast/runmiracast $(TARGET_DIR)/app/client/runmiracast
	$(INSTALL) -D -m 0755 package/google/google_miracast/miracast_player $(TARGET_DIR)/app/client/miracast_player
endef

define BCM_MIRACAST_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/src/apps/nexus_sink_app/libwfd_player.a $(STAGING_DIR)/usr/lib/libwfd_player.a
	$(INSTALL) -D -m 0644 $(@D)/src/apps/nexus_sink_app/libwfd_streamer.a $(STAGING_DIR)/usr/lib/libwfd_streamer.a
	$(INSTALL) -m 0755 -D package/google/google_miracast/S98miracast $(STAGING_DIR)/etc/init.d/S98miracast
	$(INSTALL) -D -m 0755 package/google/google_miracast/runmiracast $(STAGING_DIR)/app/client/runmiracast
	$(INSTALL) -D -m 0755 package/google/google_miracast/miracast_player $(STAGING_DIR)/app/client/miracast_player
endef

$(eval $(call GENTARGETS))
