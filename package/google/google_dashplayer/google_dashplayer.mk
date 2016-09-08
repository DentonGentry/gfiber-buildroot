#############################################################
#
# Dash player
#
#############################################################

GOOGLE_DASHPLAYER_SITE=repo://vendor/google/dashplayer
GOOGLE_DASHPLAYER_DEPENDENCIES=\
	libcurl libxml2 google_pullreader host-ninja
HOST_GOOGLE_DASHPLAYER_DEPENDENCIES=\
	$(GOOGLE_DASHPLAYER_DEPENDENCIES) \
	host-libxml2 \
	host-google_pullreader

GOOGLE_DASHPLAYER_INSTALL_STAGING=YES
GOOGLE_DASHPLAYER_INSTALL_TARGET=YES

GOOGLE_DASHPLAYER_COMMON_MAKEARGS=\
	BR2_mipsel="$(BR2_mipsel)" \
	BR2_arm="$(BR2_arm)" \
	BUILD_DIR="$(BUILD_DIR)" \
	HOST_DIR="$(HOST_DIR)" \
	INSTALL="$(INSTALL)" \
	PATH="${HOST_DIR}/usr/bin:${PATH}" \
	PYTHONDONTOPTIMIZE="0" \
	SYSROOT="$(STAGING_DIR)"

GOOGLE_DASHPLAYER_MAKE_CMD=\
	$(DASHPLAYER_MAKE_ENV) $(MAKE) -C $(@D)/build \
	$(GOOGLE_DASHPLAYER_COMMON_MAKEARGS)

define GOOGLE_DASHPLAYER_BUILD_CMDS
	$(GOOGLE_DASHPLAYER_MAKE_CMD) build
endef

define GOOGLE_DASHPLAYER_BUILD_TEST_CMDS
	$(GOOGLE_DASHPLAYER_MAKE_CMD) unittests
endef

define GOOGLE_DASHPLAYER_INSTALL_TARGET_CMDS
	$(GOOGLE_DASHPLAYER_MAKE_CMD) \
		TARGET_DIR="$(TARGET_DIR)" \
		install_target
endef

define GOOGLE_DASHPLAYER_INSTALL_STAGING_CMDS
	$(GOOGLE_DASHPLAYER_MAKE_CMD) \
		STAGING_DIR="$(STAGING_DIR)" \
		install_staging
endef

define HOST_GOOGLE_DASHPLAYER_TEST_CMDS
	$(GOOGLE_DASHPLAYER_MAKE_CMD) \
		IS_HOST_BUILD=y \
		run_unittests
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
