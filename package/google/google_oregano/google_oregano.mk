GOOGLE_OREGANO_SITE=repo://vendor/google/oregano
GOOGLE_OREGANO_DEPENDENCIES=google_dart_vm google_mcastcapture google_oregano_native

ifeq ($(BR2_PACKAGE_GOOGLE_TV_BOX),y)
GOOGLE_OREGANO_DEPENDENCIES += google_cast google_miniclient
endif

CAST_CONTROL_HEADERS=$(GOOGLE_CAST_DIR)/src/OEM_libs/public/cast_control
CAST_CONTROL_LIB_DIR=$(TARGET_DIR)/chrome

define GOOGLE_OREGANO_BUILD_CMDS
	TARGET=$(TARGET_CROSS) \
	CFLAGS="$(TARGET_CFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS) \
	-D__STDC_FORMAT_MACROS" \
	INCLUDES="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/local/include -I$(STAGING_DIR)/usr/local" \
	LIBDIRS=-L$(STAGING_DIR)/app/sage/lib \
	ARCH=$(GOOGLE_PLATFORM_ARCH) \
	MINICLIENT_PATH=$(GOOGLE_MINICLIENT_DIR) \
	CAST_CONTROL_HEADERS=$(CAST_CONTROL_HEADERS) \
	CAST_CONTROL_LIB_DIR=$(CAST_CONTROL_LIB_DIR) \
	$(MAKE) -C $(@D)
endef

define GOOGLE_OREGANO_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/app/oregano/
	mkdir -p $(TARGET_DIR)/usr/local/share/fonts
	rm -Rf $(TARGET_DIR)/usr/local/share/fonts/cc708
	$(INSTALL) -m 0755 -D package/google/google_oregano/keep_oregano_nice $(TARGET_DIR)/bin/keep_oregano_nice
	$(INSTALL) -m 0755 -D package/google/google_oregano/S99oregano $(TARGET_DIR)/etc/init.d/S99oregano
	$(INSTALL) -m 0755 -D package/google/google_oregano/S97basil $(TARGET_DIR)/etc/init.d/S97basil
	$(INSTALL) -m 0755 -D package/google/google_oregano/S95marjoram $(TARGET_DIR)/etc/init.d/S95marjoram
	$(INSTALL) -m 0755 -D $(@D)/upgradecheck $(TARGET_DIR)/usr/bin/upgradecheck
	cp -af $(@D)/* $(TARGET_DIR)/app/oregano/
	mv $(TARGET_DIR)/app/oregano/startup/assets/fonts/* $(TARGET_DIR)/usr/local/share/fonts/

	# We call into the google_oregano-native makefile to make sure the native
	# libraries are installed. See b/31031158#comment7 .
	$(call GOOGLE_OREGANO_NATIVE_INSTALL_NATIVE_LIBS,"$(GOOGLE_OREGANO_NATIVE_DIR)")
endef

$(eval $(call GENTARGETS))
