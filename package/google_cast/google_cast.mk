#############################################################
#
# google_cast
#
#############################################################

GOOGLE_CAST_DEPENDENCIES=\
	bcm_bseav bcm_nexus bcm_common bcm_rockford \
	google_miniclient libpng jpeg zlib freetype expat \
	libcurl libxml2 libxslt fontconfig boost cairo \
	avahi libcap libnss host-ninja

# This will result in defining a meaningful APPLIBS_TOP
BCM_APPS_DIR=$(abspath $(@D))

GOOGLE_CAST_INSTALL_STAGING=NO
GOOGLE_CAST_INSTALL_TARGET=YES

define GOOGLE_CAST_CONFIGURE_CMDS
	$(call BCM_COMMON_USE_BUILD_SYSTEM,$(@D))
endef

ifeq ($(BR2_CCACHE),y)
    GOOGLE_CAST_CCACHE="WEBKITGL_CCACHE=y"
else
    GOOGLE_CAST_CCACHE="WEBKITGL_CCACHE=n"
endif

define GOOGLE_CAST_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) \
		-C $(@D)/build \
		APPLIBS_PROCESS_MODEL=single \
		$(GOOGLE_CAST_CCACHE) \
		WEBKITGL_TOOLCHAIN_PATH="${HOST_DIR}/usr/bin" \
		WEBKITGL_TOOLCHAIN_SYSROOT_PATH=$(STAGING_DIR)
endef

define GOOGLE_CAST_BUILD_TEST_CMDS
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) \
		-C $(@D)/build \
		APPLIBS_PROCESS_MODEL=single \
		$(GOOGLE_CAST_CCACHE) \
		WEBKITGL_TOOLCHAIN_PATH="${HOST_DIR}/usr/bin" \
		WEBKITGL_TOOLCHAIN_SYSROOT_PATH=$(STAGING_DIR) \
		unittests
endef

define GOOGLE_CAST_INSTALL_TARGET_CMDS
	$(call BCM_COMMON_BUILD_EXTRACT_TARBALL, $(TARGET_DIR))
	if [ -e "$(TARGET_DIR)/usr/local/bin/webkitGl3/chrome-sandbox" ] ; \
		then \
			chmod 4755 "$(TARGET_DIR)/usr/local/bin/webkitGl3/chrome-sandbox"; \
		fi
endef

# Since chromium needs dlna, etc. to be rebuilt and reinstalled to its
# lib directory. We need to remove the stamp to force the reinstall.
define GOOGLE_CAST_DIRCLEAN_CMDS
	$(RM) $(@D)/common/*.stamp
endef

$(eval $(call GENTARGETS))
