# Until we add a proper java package
# :TODO: (by kedong, update BR2_GCC_SHARED_LIBGCC when new toolchain is setup)
GOOGLE_JAVA_HOME=/usr/local/buildtools/java/jdk

BRUNO_SITE=repo://vendor/google/platform
BRUNO_INSTALL_STAGING=YES
BRUNO_INSTALL_TARGET=YES
BRUNO_INSTALL_IMAGES=YES

BRUNO_DEPENDENCIES=linux humax_misc bcm_drivers bcm_nexus python py-setuptools

BRUNO_STAGING_PATH=usr/lib/bruno

define BRUNO_BUILD_CMDS
	HOSTDIR=$(HOST_DIR) \
	HOSTPYTHONPATH=$(HOST_PYTHONPATH) \
	TARGETPYTHONPATH=$(TARGET_PYTHONPATH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	BRUNO_PROD_BUILD=$(BR2_PACKAGE_BRUNO_PROD) \
	CC="$(TARGET_CC) $(TARGET_CFLAGS)" \
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(@D)/base:$(STAGING_DIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	$(MAKE) -C $(@D)
endef

define BRUNO_TEST_CMDS
	$(MAKE) -C $(@D) test
endef

define BRUNO_INSTALL_STAGING_CMDS
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(@D) install-libs
	mkdir -p $(STAGING_DIR)/$(BRUNO_STAGING_PATH)
endef

ifeq ($(BR2_PACKAGE_BRUNO_PROD),y)
BRUNO_LOADER = cfe_signed_release.bin
BRUNO_LOADER_SIG = cfe_signed_release.sig
else
BRUNO_LOADER = cfe_signed_unlocked.bin
BRUNO_LOADER_SIG = cfe_signed_unlocked.sig
endif

define BRUNO_INSTALL_TARGET_CMDS
	$(call GENIMAGEVERSION,bruno)

	HOSTDIR=$(HOST_DIR) \
	HOSTPYTHONPATH=$(HOST_PYTHONPATH) \
	DESTDIR=$(TARGET_DIR) \
	TARGETPYTHONPATH=$(TARGET_PYTHONPATH) \
	$(MAKE) -C $(@D) install

	# registercheck
	#TODO(apenwarr): do we actually need this for anything?
	mkdir -p $(TARGET_DIR)/home/test/
	cp -rf $(@D)/registercheck $(TARGET_DIR)/home/test/
endef

define BRUNO_INSTALL_IMAGES_CMDS
	if [ -n "$(BRUNO_LOADER)" ]; then \
		cp -f $(@D)/cfe/$(BRUNO_LOADER) \
			$(BINARIES_DIR)/loader.bin; \
		cp -f $(@D)/cfe/$(BRUNO_LOADER_SIG) \
			$(BINARIES_DIR)/loader.sig; \
	fi
endef

$(eval $(call GENTARGETS))
