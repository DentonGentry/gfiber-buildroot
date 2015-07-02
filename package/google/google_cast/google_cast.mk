#############################################################
#
# google_cast
#
#############################################################

# TODO(nbegley): Investigate which of these definitions are no longer necessary.

GOOGLE_CAST_SITE = repo://google_cast

GOOGLE_CAST_DEPENDENCIES=\
	bcm_bseav bcm_nexus bcm_common bcm_rockford \
	google_miniclient libpng jpeg zlib freetype expat \
	libcurl libxml2 libxslt fontconfig boost cairo \
	avahi libcap libnss host-ninja

# This will result in defining a meaningful APPLIBS_TOP (which is required by
# the local build).
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

define GOOGLE_CAST_LOCAL_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) \
		-C $(@D)/build \
		APPLIBS_PROCESS_MODEL=single \
		$(GOOGLE_CAST_CCACHE) \
		WEBKITGL_TOOLCHAIN_PATH="${HOST_DIR}/usr/bin" \
		WEBKITGL_TOOLCHAIN_SYSROOT_PATH=$(STAGING_DIR)
endef

define GOOGLE_CAST_BUILD_CMDS
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
	mkdir -p $(TARGET_DIR)/chrome/lib/

	$(INSTALL) -m 755 -D package/google/google_cast/logwrapper $(TARGET_DIR)/bin/logwrapper

	# $(INSTALL) -m 755 -D $(@D)/buildroot/cast_shell $(TARGET_DIR)/chrome/cast_shell
	# $(INSTALL) -m 4755 -D $(@D)/buildroot/chrome_sandbox $(TARGET_DIR)/chrome/chrome_sandbox
	# $(INSTALL) -m 755 -D $(@D)/buildroot/process_manager $(TARGET_DIR)/chrome/process_manager
	# $(INSTALL) -m 644 -D $(@D)/buildroot/process.json $(TARGET_DIR)/chrome/process.json

	# TOOD(nbegley): Install this to $(TARGET_DIR)/etc/init.d/ instead of /chrome once
	# we're ready to make it an init script.
	# $(INSTALL) -m 755 -D $(@D)/buildroot/S99cast.process_manager $(TARGET_DIR)/chrome/S99cast.process_manager

	# cp -afr $(@D)/buildroot/bin/* $(TARGET_DIR)/chrome/
	# cp -afr $(@D)/buildroot/lib/* $(TARGET_DIR)/chrome/lib/
endef

$(eval $(call GENTARGETS))
