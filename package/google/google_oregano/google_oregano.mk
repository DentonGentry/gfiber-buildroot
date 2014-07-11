GOOGLE_OREGANO_SITE=repo://vendor/google/oregano
GOOGLE_OREGANO_DEPENDENCIES=google_dart_vm google_mcastcapture

define GOOGLE_OREGANO_BUILD_CMDS
	TARGET=$(TARGET_CROSS) CFLAGS="$(TARGET_CFLAGS)" CXXFLAGS="$(TARGET_CXXFLAGS) -D__STDC_FORMAT_MACROS" INCLUDES=-I$(STAGING_DIR)/usr/local/include LIBDIRS=-L$(STAGING_DIR)/app/sage/lib $(MAKE) -C $(@D)
endef

define GOOGLE_OREGANO_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/app/oregano/
	$(INSTALL) -m 0755 -D package/google/google_oregano/S99oregano $(TARGET_DIR)/etc/init.d/S99oregano
	$(INSTALL) -m 0755 -D package/google/google_oregano/S95basil $(TARGET_DIR)/etc/init.d/S95basil
	$(INSTALL) -m 0755 -D package/google/google_oregano/S95marjoram $(TARGET_DIR)/etc/init.d/S95marjoram
	cp -af $(@D)/* $(TARGET_DIR)/app/oregano/
endef

$(eval $(call GENTARGETS))
