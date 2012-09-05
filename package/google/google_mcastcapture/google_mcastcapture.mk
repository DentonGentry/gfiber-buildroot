GOOGLE_MCASTCAPTURE_SITE=repo://vendor/google/mcastcapture
GOOGLE_MCASTCAPTURE_DEPENDENCIES=google_fallocate
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
endef

define GOOGLE_MCASTCAPTURE_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/sagesrv \
          $(TARGET_DIR)/app/sage/sagesrv
        $(INSTALL) -D -m 0755 $(@D)/libtxsrv.so \
          $(TARGET_DIR)/app/sage/lib/libtxsrv.so
        $(INSTALL) -D -m 0755 $(@D)/libstreamer.so \
          $(TARGET_DIR)/app/sage/lib/libstreamer.so
        $(INSTALL) -D -m 0755 $(@D)/libptsindex.so \
          $(TARGET_DIR)/app/sage/lib/libptsindex.so
endef

$(eval $(call GENTARGETS))
