#############################################################
#
# Broadcom's Chromium with custom media playback
#
#############################################################

BCM_CHROMIUM_SITE=repo://vendor/broadcom/chromium
BCM_CHROMIUM_DEPENDENCIES=\
	bcm_bseav bcm_nexus bcm_common bcm_rockford \
	google_miniclient \
	libpng jpeg zlib freetype openssl expat \
	libcurl libxml2 libxslt fontconfig
BCM_CHROMIUM_INSTALL_STAGING=NO
BCM_CHROMIUM_INSTALL_TARGET=YES

define BCM_CHROMIUM_CONFIGURE_CMDS
	$(call BCM_COMMON_USE_BUILD_SYSTEM,$(@D))
endef

ifeq ($(BR2_CCACHE),y)
    BCM_CHROMIUM_CCACHE="WEBKITGL_CCACHE=y"
else
    BCM_CHROMIUM_CCACHE="WEBKITGL_CCACHE=n"
endif

define BCM_CHROMIUM_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) \
		-C $(@D)/common dlna \
		BUILDING_DLNA=1 BUILDING_PLAYBACK_IP=1 \
		BUILDING_REFSW=1 BUILDING_DTCP_IP=0
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) \
		-C $(@D)/thirdparty/youtube/mediasource/build \
		BME_PROCESS_MODEL=single \
		TRELLIS_HAS_YOUTUBE_MEDIASOURCE=y
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) \
		-C $(@D)/thirdparty/youtube/mediasource/build \
		install
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) \
		-C $(@D)/broadcom/trellis/BME \
		BME_PROCESS_MODEL=single \
		TRELLIS_HAS_YOUTUBE_MEDIASOURCE=y
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) \
		-C $(@D)/broadcom/trellis/BME \
		BME_PROCESS_MODEL=single \
		TRELLIS_HAS_YOUTUBE_MEDIASOURCE=y \
		install
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) \
		-C $(@D)/opensource/content \
		BME_PROCESS_MODEL=single \
		$(BCM_CHROMIUM_CCACHE) \
		WEBKITGL_MPLAYER_BACKEND=bme \
		WEBKITGL_TOOLCHAIN_PATH="${HOST_DIR}/usr/bin" \
		WEBKITGL_TOOLCHAIN_SYSROOT_PATH=$(STAGING_DIR)
endef

define BCM_CHROMIUM_INSTALL_TARGET_CMDS
	$(call BCM_COMMON_BUILD_EXTRACT_TARBALL, $(TARGET_DIR))
endef

# Since chromium needs dlna, etc. to be rebuilt and reinstalled to its
# lib directory. We need to remove the stamp to force the reinstall.
define BCM_CHROMIUM_DIRCLEAN_CMDS
	$(RM) $(@D)/common/*.stamp
endef

$(eval $(call GENTARGETS))
