GOOGLE_SAGEJNI_SITE=repo://vendor/google/sagejni
GOOGLE_SAGEJNI_DEPENDENCIES=linux

define GOOGLE_SAGEJNI_BUILD_CMDS
        JAVA_HOME=$(GOOGLE_JAVA_HOME) \
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_SAGEJNI_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/libSage.so $(TARGET_DIR)/app/sage/lib/libSage.so
endef

$(eval $(call GENTARGETS_NEW))
