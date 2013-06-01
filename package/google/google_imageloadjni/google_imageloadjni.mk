GOOGLE_IMAGELOADJNI_SITE=repo://vendor/google/imageloadjni
GOOGLE_IMAGELOADJNI_DEPENDENCIES=libpng jpeg libungif tiff host-pkg-config

define GOOGLE_IMAGELOADJNI_BUILD_CMDS
        PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
        PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
        PKG_CONFIG_PATH="$(STAGING_DIR)/usr/local/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
        JAVA_HOME=$(GOOGLE_JAVA_HOME) \
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_IMAGELOADJNI_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/libImageLoader.so $(TARGET_DIR)/app/sage/lib/libImageLoader.so
endef

$(eval $(call GENTARGETS))
