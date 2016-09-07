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

GOOGLE_DASHPLAYER_STANDARD_MAKEARGS=\
	PATH="${HOST_DIR}/usr/bin:${PATH}" \
	PYTHONDONTOPTIMIZE="0" \
	SYSROOT="$(STAGING_DIR)" \
	BUILD_DIR="$(BUILD_DIR)" \
	HOST_DIR="$(HOST_DIR)" \
	BR2_mipsel="$(BR2_mipsel)" \
	BR2_arm="$(BR2_arm)"

define GOOGLE_DASHPLAYER_BUILD_CMDS
	$(DASHPLAYER_MAKE_ENV) $(MAKE) -C $(@D)/build \
		$(GOOGLE_DASHPLAYER_STANDARD_MAKEARGS)
endef

define GOOGLE_DASHPLAYER_BUILD_TEST_CMDS
	$(DASHPLAYER_MAKE_ENV) $(MAKE) -C $(@D)/build \
		$(GOOGLE_DASHPLAYER_STANDARD_MAKEARGS) \
		unittests
endef

define GOOGLE_DASHPLAYER_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/app/client/
	$(INSTALL) -D -m 0755 $(@D)/src/out/Release/lib/libdashplayer.so $(TARGET_DIR)/app/client/
	$(STRIPCMD) $(TARGET_DIR)/app/client/libdashplayer.so
endef

define GOOGLE_DASHPLAYER_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/src/out/Release/lib/libdashplayer.so $(STAGING_DIR)/usr/local/lib/
	$(INSTALL) -D -m 0644 $(@D)/src/dashplayer/dash.h $(STAGING_DIR)/usr/local/include/
endef

define HOST_GOOGLE_DASHPLAYER_TEST_CMDS
	$(DASHPLAYER_MAKE_ENV) $(MAKE) -C $(@D)/build \
		$(GOOGLE_DASHPLAYER_STANDARD_MAKEARGS) \
		IS_HOST_BUILD=y \
		run_unittests
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
