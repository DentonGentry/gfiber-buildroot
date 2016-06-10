GOOGLE_TVSTREAMPARSER_SITE=repo://vendor/google/tvstreamparser
GOOGLE_TVSTREAMPARSER_DEPENDENCIES=

define GOOGLE_TVSTREAMPARSER_BUILD_CMDS
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)/tvstreamparser
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)/channel
endef

define GOOGLE_TVSTREAMPARSER_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/tvstreamparser/libtvstreamparser.so \
          $(TARGET_DIR)/app/sage/lib/libtvstreamparser.so
        $(INSTALL) -D -m 0755 $(@D)/tvstreamparser/filefmt \
          $(TARGET_DIR)/app/sage/filefmt
endef

$(eval $(call GENTARGETS))
