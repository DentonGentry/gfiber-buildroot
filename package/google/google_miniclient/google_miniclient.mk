GOOGLE_MINICLIENT_SITE=repo://vendor/sagetv/miniclient
GOOGLE_MINICLIENT_DEPENDENCIES=\
	linux \
	bcm_nexus bcm_rockford \
	google_pullreader google_swscale google_widevine google_hdcp \
	openssl libcurl tiff zlib libpng libungif libprojectM libxml2

define GOOGLE_MINICLIENT_BUILD_CMDS
        PULLREADER_PATH=$(STAGING_DIR)/usr/local/ \
        SWSCALE_PATH=$(STAGING_DIR)/usr/local/ \
        $(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D) -f Makefile.7425 all
endef

define GOOGLE_MINICLIENT_INSTALL_TARGET_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D) -f Makefile.7425 \
		DESTDIR=$(TARGET_DIR) install
        $(INSTALL) -m 0755 -D package/google/google_miniclient/S99miniclient $(TARGET_DIR)/etc/init.d/S99miniclient; \
        $(INSTALL) -D -m 0755 package/google/google_miniclient/run-app $(TARGET_DIR)/app/client/run-app
        $(INSTALL) -D -m 0755 package/google/google_miniclient/runminiclient $(TARGET_DIR)/app/client/runminiclient
endef

$(eval $(call GENTARGETS))
