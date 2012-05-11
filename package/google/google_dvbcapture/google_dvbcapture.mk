GOOGLE_DVBCAPTURE_SITE=repo://vendor/google/dvbcapture
GOOGLE_DVBCAPTURE_DEPENDENCIES=linux google_tvstreamparser

define GOOGLE_DVBCAPTURE_BUILD_CMDS
        TVSTREAMPARSER_PATH=$(GOOGLE_TVSTREAMPARSER_DIR)/tvstreamparser/ \
        JAVA_HOME=$(GOOGLE_JAVA_HOME) \
        TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_DVBCAPTURE_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/libDVBCapture.so $(TARGET_DIR)/app/sage/lib/libDVBCapture.so
endef

$(eval $(call GENTARGETS))
