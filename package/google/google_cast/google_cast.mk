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
	avahi libcap libnss host-gyp host-ninja google_widevine_cenc

# This will result in defining a meaningful APPLIBS_TOP (which is required by
# the local build).
BCM_APPS_DIR=$(abspath $(@D))

GOOGLE_CAST_INSTALL_STAGING=NO
GOOGLE_CAST_INSTALL_TARGET=YES

PLATFORM=$(BR2_PACKAGE_BCM_COMMON_PLATFORM)
BCHP_VER_LOWER=$(shell echo $(BR2_PACKAGE_BCM_COMMON_PLATFORM_REV) | tr A-Z a-z)
BUILD_TYPE_LOWER=$(shell echo $(BUILD_TYPE) | tr A-Z a-z)

ifdef BR2_mipsel
BCM_ARCH=mips
B_REFSW_ARCH=mipsel-linux
else
BCM_ARCH=arm
B_REFSW_ARCH=arm-linux
endif

ifeq ($(BR2_PACKAGE_BCM_COMMON_PLATFORM),"97439")
V3D_PREFIX=vc5
else
V3D_PREFIX=v3d
endif

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
                -f Makefile.oemlibs \
		$(GOOGLE_CAST_CCACHE) \
		PYTHONDONTOPTIMIZE="0" \
		BUILD_DIR=$(BUILD_DIR) \
		TARGET_ARCH="$(BR2_ARCH)" \
		TARGET_CROSS="$(TARGET_CROSS)" \
		V3D_PREFIX="$(V3D_PREFIX)"
endef

define GOOGLE_CAST_BUILD_TEST_CMDS
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) \
		-C $(@D)/build \
		$(GOOGLE_CAST_CCACHE) \
		PYTHONDONTOPTIMIZE="0" \
		unittests
endef

define GOOGLE_CAST_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/chrome/lib/
	mkdir -p $(TARGET_DIR)/oem_cast_shlib/

	# TODO(sfunkenhauser): Remove these once this path is no longer
	# hard-coded in drm_context.cc.
	ln -sf /user/drm $(TARGET_DIR)/data

	$(call GOOGLE_CAST_INSTALL_BINARIES)
endef

define GOOGLE_CAST_INSTALL_BINARIES
	cp -afr $(@D)/bin/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/cast_binaries/* $(TARGET_DIR)/chrome/
	if [ -e $(@D)/target/$(PLATFORM)$(BCHP_VER_LOWER).$(B_REFSW_ARCH).$(BUILD_TYPE_LOWER) ]; then \
		cp -af $(@D)/target/$(PLATFORM)$(BCHP_VER_LOWER).$(B_REFSW_ARCH).$(BUILD_TYPE_LOWER)/bin/logwrapper $(TARGET_DIR)/bin/logwrapper ; \
		cp -afr $(@D)/target/$(PLATFORM)$(BCHP_VER_LOWER).$(B_REFSW_ARCH).$(BUILD_TYPE_LOWER)/chrome/* $(TARGET_DIR)/chrome/ ; \
		cp -afr $(@D)/target/$(PLATFORM)$(BCHP_VER_LOWER).$(B_REFSW_ARCH).$(BUILD_TYPE_LOWER)/oem_cast_shlib/* $(TARGET_DIR)/oem_cast_shlib/ ; \
	else \
		cp -af $(@D)/target/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/bin/logwrapper $(TARGET_DIR)/bin/logwrapper ; \
		cp -afr $(@D)/target/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/chrome/* $(TARGET_DIR)/chrome/ ; \
		cp -afr $(@D)/target/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/oem_cast_shlib/* $(TARGET_DIR)/oem_cast_shlib/ ; \
	fi

	mv $(TARGET_DIR)/chrome/chrome_sandbox $(TARGET_DIR)/chrome/chrome-sandbox

	$(INSTALL) -D -m 0644 $(@D)/bin/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/scripts/process.json $(TARGET_DIR)/chrome/process.json
	$(INSTALL) -D -m 0755 $(@D)/build/S99cast.process_manager $(TARGET_DIR)/etc/init.d/S99cast.process_manager
	$(INSTALL) -D -m 0755 $(@D)/build/start_cast_process_manager $(TARGET_DIR)/chrome/start_cast_process_manager
	$(INSTALL) -D -m 0755 $(@D)/build/start_cert_fetcher $(TARGET_DIR)/chrome/start_cert_fetcher

	chmod 4755 $(TARGET_DIR)/chrome/chrome-sandbox
endef

$(eval $(call GENTARGETS))
