GOOGLE_MPEGPARSER_SITE=repo://vendor/google/mpegparser
GOOGLE_MPEGPARSER_DEPENDENCIES=google_tvstreamparser google_mcastcapture

define GOOGLE_MPEGPARSER_BUILD_CMDS
        STAGING_DIR=$(STAGING_DIR) \
        TVSTREAMPARSER_PATH=$(GOOGLE_TVSTREAMPARSER_DIR)/tvstreamparser/ \
        JAVA_HOME=$(GOOGLE_JAVA_HOME) \
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_MPEGPARSER_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/libMPEGParser.so \
          $(TARGET_DIR)/app/sage/lib/libMPEGParser.so
endef

$(eval $(call GENTARGETS))
