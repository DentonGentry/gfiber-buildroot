GOOGLE_MPEGPARSER_SITE=repo://vendor/google/mpegparser
GOOGLE_MPEGPARSER_DEPENDENCIES=linux google_tvstreamparser

define GOOGLE_MPEGPARSER_BUILD_CMDS
        TVSTREAMPARSER_PATH=$(GOOGLE_TVSTREAMPARSER_DIR)/tvstreamparser/ \
        JAVA_HOME=$(GOOGLE_JAVA_HOME) \
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_MPEGPARSER_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/libMPEGParser.so \
          $(TARGET_DIR)/app/sage/lib/libMPEGParser.so
endef

$(eval $(call GENTARGETS))
