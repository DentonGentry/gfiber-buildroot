GOOGLE_OREGANO_SITE=repo://vendor/google/oregano
GOOGLE_OREGANO_DEPENDENCIES=google_dart_vm google_mcastcapture

ifeq      ($(BR2_arm),y)
GOOGLE_PLATFORM_ARCH   := arm
else ifeq ($(BR2_mips),y)
GOOGLE_PLATFORM_ARCH   := mips
else ifeq ($(BR2_mipsel),y)
GOOGLE_PLATFORM_ARCH   := mips
else ifeq ($(BR2_i386),y)
GOOGLE_PLATFORM_ARCH   := i386
endif

define GOOGLE_OREGANO_BUILD_CMDS
	TARGET=$(TARGET_CROSS) \
	CFLAGS="$(TARGET_CFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS) \
	-D__STDC_FORMAT_MACROS" \
	INCLUDES="-I$(STAGING_DIR)/usr/local/include -I$(STAGING_DIR)/usr/local" \
	LIBDIRS=-L$(STAGING_DIR)/app/sage/lib \
	ARCH=$(GOOGLE_PLATFORM_ARCH) \
	$(MAKE) -C $(@D)
endef

define GOOGLE_OREGANO_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/app/oregano/
	mkdir -p $(TARGET_DIR)/usr/local/share/fonts
	rm -Rf $(TARGET_DIR)/usr/local/share/fonts/cc708
	$(INSTALL) -m 0755 -D package/google/google_oregano/S99oregano $(TARGET_DIR)/etc/init.d/S99oregano
	$(INSTALL) -m 0755 -D package/google/google_oregano/S97basil $(TARGET_DIR)/etc/init.d/S97basil
	$(INSTALL) -m 0755 -D package/google/google_oregano/S95marjoram $(TARGET_DIR)/etc/init.d/S95marjoram
	$(INSTALL) -m 0755 -D $(@D)/upgradecheck $(TARGET_DIR)/usr/bin/upgradecheck
	cp -af $(@D)/* $(TARGET_DIR)/app/oregano/
	mv $(TARGET_DIR)/app/oregano/startup/assets/fonts/* $(TARGET_DIR)/usr/local/share/fonts/
endef

$(eval $(call GENTARGETS))
