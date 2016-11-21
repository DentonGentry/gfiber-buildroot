#############################################################
#
# google_cast
#
#############################################################

GOOGLE_CAST_SITE = repo://google_cast

# TODO(smcgruer): At least some of these dependencies are not needed.
GOOGLE_CAST_DEPENDENCIES=\
	bcm_bseav bcm_nexus bcm_common bcm_rockford \
	google_miniclient libpng jpeg zlib freetype expat \
	libcurl libxml2 libxslt fontconfig boost cairo \
	avahi libcap libnss host-gyp host-ninja google_widevine_cenc

GOOGLE_CAST_INSTALL_STAGING=NO
GOOGLE_CAST_INSTALL_TARGET=YES

# Rather than include all of BCM_MAKEFLAGS, we calculate the only necessary one
# here, which is the rockford gl prefix.
ifeq ($(BR2_PACKAGE_BCM_COMMON_PLATFORM),"97439")
V3D_PREFIX=vc5
else
V3D_PREFIX=v3d
endif

# The standard set of Make arguments that we need. In particular, BCM_MAKE_ENV
# contains many necessary variables for working with NEXUS.
GOOGLE_CAST_MAKEARGS=\
	$(BCM_MAKE_ENV) \
	BUILD_DIR=$(BUILD_DIR) \
	PATH="${HOST_DIR}/usr/bin:${PATH}" \
	TARGET_ARCH="$(BR2_ARCH)" \
	TARGET_CROSS="$(TARGET_CROSS)" \
	V3D_PREFIX="$(V3D_PREFIX)"

define GOOGLE_CAST_BUILD_CMDS
	$(MAKE) \
		-C $(@D)/build \
                -f Makefile.oemlibs \
		$(GOOGLE_CAST_MAKEARGS)
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
	cp -af $(@D)/target/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/bin/logwrapper $(TARGET_DIR)/bin/logwrapper ; \
	cp -afr $(@D)/target/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/chrome/* $(TARGET_DIR)/chrome/ ; \
	cp -afr $(@D)/target/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/oem_cast_shlib/* $(TARGET_DIR)/oem_cast_shlib/ ; \

	mv $(TARGET_DIR)/chrome/chrome_sandbox $(TARGET_DIR)/chrome/chrome-sandbox

	$(INSTALL) -D -m 0644 $(@D)/bin/$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/scripts/process.json $(TARGET_DIR)/chrome/process.json
	$(INSTALL) -D -m 0755 $(@D)/build/S99cast.process_manager $(TARGET_DIR)/etc/init.d/S99cast.process_manager
	$(INSTALL) -D -m 0755 $(@D)/build/start_cast_process_manager $(TARGET_DIR)/chrome/start_cast_process_manager
	$(INSTALL) -D -m 0755 $(@D)/build/start_cert_fetcher $(TARGET_DIR)/chrome/start_cert_fetcher

	chmod 4755 $(TARGET_DIR)/chrome/chrome-sandbox
endef

$(eval $(call GENTARGETS))
