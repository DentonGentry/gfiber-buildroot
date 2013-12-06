GOOGLE_MCASTCAPTURE_SITE=repo://vendor/google/mcastcapture
GOOGLE_MCASTCAPTURE_DEPENDENCIES=google_fallocate openssl libcurl
GOOGLE_MCASTCAPTURE_INSTALL_STAGING = YES

define GOOGLE_MCASTCAPTURE_BUILD_CMDS
        TARGET=$(TARGET_CROSS) FALLOCATE_GLIBC_MISSING=yes $(MAKE) -C $(@D)
endef

define GOOGLE_MCASTCAPTURE_INSTALL_STAGING_CMDS
        mkdir -p $(STAGING_DIR)/usr/include/pts_index
        $(INSTALL) -D -m 0444 $(@D)/pts_index/index_file.h \
          $(STAGING_DIR)/usr/include/pts_index
        $(INSTALL) -D -m 0444 $(@D)/pts_index/verify_index.h \
          $(STAGING_DIR)/usr/include/pts_index
        $(INSTALL) -D -m 0444 $(@D)/pts_index/pts_indexer.h \
          $(STAGING_DIR)/usr/include/pts_index
        mkdir -p $(STAGING_DIR)/app/sage/lib
        $(INSTALL) -D -m 0755 $(@D)/pts_index/libptsindex.so \
          $(STAGING_DIR)/app/sage/lib
endef

define GOOGLE_MCASTCAPTURE_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/sagesrv \
          $(TARGET_DIR)/app/sage/sagesrv
        $(INSTALL) -D -m 0755 $(@D)/media_pull_server/libtxsrv.so \
          $(TARGET_DIR)/app/sage/lib/libtxsrv.so
        $(INSTALL) -D -m 0755 $(@D)/media_push_server/libstreamer.so \
          $(TARGET_DIR)/app/sage/lib/libstreamer.so
        $(INSTALL) -D -m 0755 $(@D)/pts_index/libptsindex.so \
          $(TARGET_DIR)/app/sage/lib/libptsindex.so
        $(INSTALL) -D -m 0755 $(@D)/tv_format/libtvformat.so \
          $(TARGET_DIR)/app/sage/lib/libtvformat.so
        $(INSTALL) -D -m 0755 $(@D)/ads/libads.so \
          $(TARGET_DIR)/app/sage/lib/libads.so
endef

define GOOGLE_MCASTCAPTURE_TEST_CMDS
        $(MAKE) -C $(@D) test
endef

$(eval $(call GENTARGETS))
