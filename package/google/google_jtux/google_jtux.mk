GOOGLE_JTUX_SITE=repo://vendor/google/jtux
GOOGLE_JTUX_DEPENDENCIES=linux

define GOOGLE_JTUX_BUILD_CMDS
        JAVA_HOME=$(GOOGLE_JAVA_HOME) \
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_JTUX_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/libjtux.so $(TARGET_DIR)/app/sage/lib/libjtux.so
endef

$(eval $(call GENTARGETS_NEW))
