GOOGLE_FREETYPEJNI_SITE=repo://vendor/google/freetypejni
GOOGLE_FREETYPEJNI_DEPENDENCIES=linux freetype

define GOOGLE_FREETYPEJNI_BUILD_CMDS
        PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
        PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
        PKG_CONFIG_PATH="$(STAGING_DIR)/usr/local/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
        JAVA_HOME=$(GOOGLE_JAVA_HOME) \
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_FREETYPEJNI_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/libFreetypeFontJNI.so $(TARGET_DIR)/app/sage/lib/libFreetypeFontJNI.so
endef

$(eval $(call GENTARGETS))
