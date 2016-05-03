#############################################################
#
# Dash player
#
#############################################################

DASHPLAYER_SITE=repo://vendor/google/dashplayer
CHROMIUM_DEPENDENCIES=\
	bcm_bseav bcm_nexus bcm_common bcm_rockford \
	google_miniclient zlib openssl expat \
	libcurl libxml2 libxslt host-ninja

# This will result in defining a meaningful APPLIBS_TOP
BCM_APPS_DIR=$(abspath $(@D))

DASHPLAYER_INSTALL_STAGING=NO
DASHPLAYER_INSTALL_TARGET=YES

define DASHPLAYER_CONFIGURE_CMDS
	$(call BCM_COMMON_USE_BUILD_SYSTEM,$(@D))
endef

define DASHPLAYER_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) \
		-C $(@D)/build \
		PYTHONDONTOPTIMIZE="0" \
		SYSROOT=$(STAGING_DIR) \
		BUILD_DIR=$(BUILD_DIR)
endef

define DASHPLAYER_BUILD_TEST_CMDS
	$(BCM_MAKE_ENV) $(MAKE) \
		$(BCM_MAKEFLAGS) \
		-C $(@D)/build \
		$(DASHPLAYER_CCACHE) \
		PYTHONDONTOPTIMIZE="0" \
		SYSROOT=$(STAGING_DIR) \
		BUILD_DIR=$(BUILD_DIR) \
		unittests
endef

define DASHPLAYER_INSTALL_TARGET_CMDS
# TODO
endef

$(eval $(call GENTARGETS))
