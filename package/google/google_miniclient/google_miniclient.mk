GOOGLE_MINICLIENT_SITE=repo://vendor/sagetv/miniclient
GOOGLE_MINICLIENT_DEPENDENCIES=linux bcm_nexus bcm_rockford google_pullreader openssl libcurl google_swscale tiff zlib libpng libungif google_widevine


define GOOGLE_MINICLIENT_BUILD_CMDS
        PULLREADER_PATH=$(STAGING_DIR)/usr/local/ \
        SWSCALE_PATH=$(STAGING_DIR)/usr/local/ \
        $(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D) -f Makefile.7425
endef

define GOOGLE_MINICLIENT_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/miniclient $(TARGET_DIR)/app/client/miniclient
        $(INSTALL) -m 0755 -D package/google/google_miniclient/S99miniclient $(TARGET_DIR)/etc/init.d/S99miniclient; \
        $(INSTALL) -D -m 0755 package/google/google_miniclient/run-app $(TARGET_DIR)/app/client/run-app
        $(INSTALL) -D -m 0755 package/google/google_miniclient/runminiclient $(TARGET_DIR)/app/client/runminiclient
endef

$(eval $(call GENTARGETS,package/google,google_miniclient))
