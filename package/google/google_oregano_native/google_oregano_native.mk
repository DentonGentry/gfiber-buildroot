GOOGLE_OREGANO_NATIVE_SITE=repo://vendor/google/oregano-native
GOOGLE_OREGANO_NATIVE_DEPENDENCIES=google_dart_vm google_mcastcapture

ifeq ($(BR2_PACKAGE_GOOGLE_TV_BOX),y)
GOOGLE_OREGANO_NATIVE_DEPENDENCIES += google_miniclient
endif

define GOOGLE_OREGANO_NATIVE_BUILD_CMDS
	$(MAKE) -C "$(@D)" \
		CROSS_PREFIX="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CXXFLAGS) -D__STDC_FORMAT_MACROS" \
		ARCH="$(GOOGLE_PLATFORM_ARCH)" \
		MINICLIENT_PATH="$(GOOGLE_MINICLIENT_DIR)" \
		STAGING_DIR="$(STAGING_DIR)" \
		IS_TV_BOX="$(BR2_PACKAGE_GOOGLE_TV_BOX)" \
		IS_STORAGE_BOX="$(BR2_PACKAGE_GOOGLE_STORAGE_BOX)" \
		build
endef

# The google_oregano package also installs our libraries to ensure that the
# native libaries are always installed. (See b/31031158#comment7). Therefore,
# we define our install step as a method that can be called by anyone.
define GOOGLE_OREGANO_NATIVE_INSTALL_NATIVE_LIBS
	$(MAKE) -C "$(1)" \
		CROSS_PREFIX="$(TARGET_CROSS)" \
		ARCH="$(GOOGLE_PLATFORM_ARCH)" \
		DESTDIR="$(TARGET_DIR)" \
		INSTALL="$(INSTALL)" \
		IS_TV_BOX="$(BR2_PACKAGE_GOOGLE_TV_BOX)" \
		IS_STORAGE_BOX="$(BR2_PACKAGE_GOOGLE_STORAGE_BOX)" \
		install
endef

define GOOGLE_OREGANO_NATIVE_INSTALL_TARGET_CMDS
	$(call GOOGLE_OREGANO_NATIVE_INSTALL_NATIVE_LIBS,"$(@D)")
endef

$(eval $(call GENTARGETS))
