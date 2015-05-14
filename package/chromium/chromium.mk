#############################################################
#
# Chromium
#
#############################################################

CHROMIUM_SITE=rrepo://chromium
CHROMIUM_DEPENDENCIES=\
	bcm_bseav bcm_nexus bcm_common bcm_rockford bcm_trellis \
	google_miniclient \
	libpng jpeg zlib freetype openssl expat \
	libcurl libxml2 libxslt fontconfig boost \
	cairo avahi libcap libnss host-ninja

# This will result in defining a meaningful APPLIBS_TOP
BCM_APPS_DIR=$(abspath $(@D))

CHROMIUM_INSTALL_STAGING=NO
CHROMIUM_INSTALL_TARGET=YES

define CHROMIUM_CONFIGURE_CMDS
	$(call BCM_COMMON_USE_BUILD_SYSTEM,$(@D))
endef

ifeq ($(BR2_CCACHE),y)
    CHROMIUM_CCACHE="WEBKITGL_USE_CCACHE=$(CCACHE)"
else
    CHROMIUM_CCACHE="WEBKITGL_USE_CCACHE="
endif

ifeq ($(BR2_PACKAGE_CHROMIUM_DISABLE_CHROMECAST),y)
    DISABLE_CHROMECAST=1
else
    DISABLE_CHROMECAST=1
endif

define CHROMIUM_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) \
		-C $(@D)/build \
		APPLIBS_PROCESS_MODEL=single \
		$(CHROMIUM_CCACHE) \
		WEBKITGL_TOOLCHAIN_PATH="${HOST_DIR}/usr/bin" \
		WEBKITGL_TOOLCHAIN_SYSROOT_PATH=$(STAGING_DIR) \
		TRELLIS_HAS_YOUTUBE_MEDIASOURCE=n \
		DISABLE_CHROMECAST=$(DISABLE_CHROMECAST)
endef

define CHROMIUM_BUILD_TEST_CMDS
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) \
		-C $(@D)/build \
		APPLIBS_PROCESS_MODEL=single \
		$(CHROMIUM_CCACHE) \
		WEBKITGL_TOOLCHAIN_PATH="${HOST_DIR}/usr/bin" \
		WEBKITGL_TOOLCHAIN_SYSROOT_PATH=$(STAGING_DIR) \
		TRELLIS_HAS_YOUTUBE_MEDIASOURCE=y unittests
endef

define CHROMIUM_INSTALL_TARGET_CMDS
	$(call BCM_COMMON_BUILD_EXTRACT_TARBALL, $(TARGET_DIR))
	if [ -e "$(TARGET_DIR)/usr/local/bin/webkitGl3/chrome-sandbox" ] ; \
		then \
			chmod 4755 "$(TARGET_DIR)/usr/local/bin/webkitGl3/chrome-sandbox"; \
		fi
endef

# Since chromium needs dlna, etc. to be rebuilt and reinstalled to its
# lib directory. We need to remove the stamp to force the reinstall.
define CHROMIUM_DIRCLEAN_CMDS
	$(RM) $(@D)/common/*.stamp
endef

$(eval $(call GENTARGETS))
