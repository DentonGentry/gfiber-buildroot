BCM_VUDU_SITE=repo://vendor/broadcom/vudu
BCM_VUDU_DEPENDENCIES=bcm_bseav bcm_magnum bcm_nexus bcm_common \
  google_hdcp libpng jpeg zlib freetype openssl expat \
  libcurl libxml2 libxslt fontconfig google_miniclient \

BCM_VUDU_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/vudu
BCM_VUDU_INSTALL_TARGET=YES

BCM_VUDU_SDK_VERSION=vudu_3.1.0_rev_121183

define BCM_VUDU_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) -C $(@D)/build
endef

define BCM_VUDU_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -D $(@D)/bin/vudu $(TARGET_DIR)/usr/local/bin/vudu/vudu
	$(INSTALL) -m 755 -D $(@D)/$(BCM_VUDU_SDK_VERSION)/lib/libavcodec.so.52.20.0 $(TARGET_DIR)/usr/local/bin/vudu/libavcodec.so.52.20.0
	ln -s -f libavcodec.so.52.20.0 $(TARGET_DIR)/usr/local/bin/vudu/libavcodec.so
	ln -s -f libavcodec.so.52.20.0 $(TARGET_DIR)/usr/local/bin/vudu/libavcodec.so.52
	$(INSTALL) -m 755 -D $(@D)/$(BCM_VUDU_SDK_VERSION)/lib/libavformat.so.52.31.0 $(TARGET_DIR)/usr/local/bin/vudu/libavformat.so.52.31.0
	ln -s -f libavformat.so.52.31.0 $(TARGET_DIR)/usr/local/bin/vudu/libavformat.so
	ln -s -f libavformat.so.52.31.0 $(TARGET_DIR)/usr/local/bin/vudu/libavformat.so.52
	$(INSTALL) -m 755 -D $(@D)/$(BCM_VUDU_SDK_VERSION)/lib/libavutil.so.49.15.0 $(TARGET_DIR)/usr/local/bin/vudu/libavutil.so.49.15.0
	ln -s -f libavutil.so.49.15.0 $(TARGET_DIR)/usr/local/bin/vudu/libavutil.so
	ln -s -f libavutil.so.49.15.0 $(TARGET_DIR)/usr/local/bin/vudu/libavutil.so.49
	$(INSTALL) -m 755 -D $(@D)/$(BCM_VUDU_SDK_VERSION)/lib/liblzma.so.5 $(TARGET_DIR)/usr/local/bin/vudu/liblzma.so.5
endef

$(eval $(call GENTARGETS))
