GOOGLE_MCASTCAPTURE_SITE=repo://vendor/google/mcastcapture
GOOGLE_MCASTCAPTURE_DEPENDENCIES=google_fallocate

define GOOGLE_MCASTCAPTURE_BUILD_CMDS
        TARGET=$(TARGET_CROSS) FALLOCATE_GLIBC_MISSING=yes $(MAKE) -C $(@D)
endef

define GOOGLE_MCASTCAPTURE_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/sagesrv \
          $(TARGET_DIR)/app/sage/sagesrv
        $(INSTALL) -D -m 0755 $(@D)/libtxsrv.so \
          $(TARGET_DIR)/app/sage/lib/libtxsrv.so
        $(INSTALL) -D -m 0755 $(@D)/libstreamer.so \
          $(TARGET_DIR)/app/sage/lib/libstreamer.so
endef

$(eval $(call GENTARGETS,package/google,google_mcastcapture))
