# Until we add a proper java package
# :TODO: (by kedong, update BR2_GCC_SHARED_LIBGCC when new toolchain is setup)
GOOGLE_JAVA_HOME=/usr/local/buildtools/java/jdk

BRUNO_SITE=repo://vendor/google/platform
BRUNO_INSTALL_STAGING=YES
BRUNO_INSTALL_TARGET=YES
BRUNO_STAGING_PATH=usr/lib/bruno
BRUNO_DEPENDENCIES=humax_misc python py-setuptools
BRUNO_DEPENDENCIES+=host-python-crypto

define BRUNO_BUILD_CMDS
	HOSTDIR=$(HOST_DIR) \
	HOSTPYTHONPATH=$(HOST_PYTHONPATH) \
	TARGETPYTHONPATH=$(TARGET_PYTHONPATH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	BRUNO_PROD_BUILD=$(BR2_PACKAGE_GOOGLE_PROD) \
	CC="$(TARGET_CC) $(TARGET_CFLAGS)" \
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(@D)/base:$(STAGING_DIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	$(MAKE) -C $(@D)
endef

define BRUNO_TEST_CMDS
	PYTHON=$(HOST_DIR)/usr/bin/python $(MAKE) -C $(@D) test
endef

define BRUNO_INSTALL_STAGING_CMDS
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(@D) install-libs
	mkdir -p $(STAGING_DIR)/$(BRUNO_STAGING_PATH)
endef

define BRUNO_INSTALL_TARGET_CMDS
	$(call GENIMAGEVERSION,gfibertv)
	HOSTDIR=$(HOST_DIR) \
	HOSTPYTHONPATH=$(HOST_PYTHONPATH) \
	DESTDIR=$(TARGET_DIR) \
	TARGETPYTHONPATH=$(TARGET_PYTHONPATH) \
	BRUNO_PROD_BUILD=$(BR2_PACKAGE_GOOGLE_PROD) \
	$(MAKE) -C $(@D) install

	# registercheck
	#TODO(apenwarr): do we actually need this for anything?
	mkdir -p $(TARGET_DIR)/home/test/
	cp -rf $(@D)/registercheck $(TARGET_DIR)/home/test/
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
