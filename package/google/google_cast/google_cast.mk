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

ifdef BR2_mipsel
BCM_ARCH=mips
else
BCM_ARCH=arm
endif

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
		PYTHONDONTOPTIMIZE="0" \
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
		PYTHONDONTOPTIMIZE="0" \
		WEBKITGL_TOOLCHAIN_PATH="${HOST_DIR}/usr/bin" \
		WEBKITGL_TOOLCHAIN_SYSROOT_PATH=$(STAGING_DIR) \
		unittests
endef

define GOOGLE_CAST_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/chrome/lib/

	# TODO(sfunkenhauser): Remove these once this path is no longer
	# hard-coded in drm_context.cc.
	ln -sf /user/drm $(TARGET_DIR)/data

	# TODO(sfunkenhauser) : We currently can't build cast binaries for our ARM
	# platform.  Only copy over cast shell binaries for MIPS for the time being.
	$(if $(filter $(BCM_ARCH),mips),$(call GOOGLE_CAST_INSTALL_BINARIES),)
endef

define GOOGLE_CAST_INSTALL_BINARIES
	cp -af $(@D)/bin/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/logwrapper $(TARGET_DIR)/bin/logwrapper

	cp -afr $(@D)/bin/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/bin/* $(TARGET_DIR)/chrome/
	cp -afr $(@D)/bin/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/lib/* $(TARGET_DIR)/chrome/lib/

	$(INSTALL) -D -m 0644 $(@D)/build/process.json $(TARGET_DIR)/chrome/process.json
	$(INSTALL) -D -m 0755 $(@D)/build/S99cast.process_manager $(TARGET_DIR)/etc/init.d/S99cast.process_manager
	$(INSTALL) -D -m 0755 $(@D)/build/start_cast_process_manager $(TARGET_DIR)/chrome/start_cast_process_manager
	$(INSTALL) -D -m 0755 $(@D)/build/start_cast_shell $(TARGET_DIR)/chrome/start_cast_shell
	$(INSTALL) -D -m 0755 $(@D)/build/start_cert_fetcher $(TARGET_DIR)/chrome/start_cert_fetcher

	chmod 4755 $(TARGET_DIR)/chrome/chrome-sandbox
endef

$(eval $(call GENTARGETS))
