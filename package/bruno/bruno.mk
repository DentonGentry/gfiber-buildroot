# Until we add a proper java package
GOOGLE_JAVA_HOME=/usr/local/buildtools/java/jdk

BRUNO_SITE=repo://vendor/google/platform
BRUNO_INSTALL_STAGING=YES
BRUNO_INSTALL_TARGET=YES
BRUNO_STAGING_PATH=usr/lib/bruno
BRUNO_DEPENDENCIES=humax_misc python py-setuptools
BRUNO_DEPENDENCIES+=host-python-crypto host-py-mox

ifeq      ($(BR2_arm),y)
BRUNO_ARCH   := arm
else ifeq ($(BR2_mips),y)
BRUNO_ARCH   := mips
else ifeq ($(BR2_mipsel),y)
BRUNO_ARCH   := mips
else ifeq ($(BR2_i386),y)
BRUNO_ARCH   := i386
endif

define BRUNO_BUILD_CMDS
	HOSTDIR=$(HOST_DIR) \
	PYTHONPATH=$(HOST_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	CROSS_COMPILE=$(TARGET_CROSS) \
	BRUNO_PROD_BUILD=$(BR2_PACKAGE_GOOGLE_PROD) \
	CC="$(TARGET_CC) $(TARGET_CFLAGS)" \
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(@D)/base:$(STAGING_DIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	BRUNO_ARCH=$(BRUNO_ARCH) \
	$(MAKE) -C $(@D)
endef

define BRUNO_TEST_CMDS
	PYTHONPATH=$(HOST_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python $(MAKE) -C $(@D) test
endef

define BRUNO_INSTALL_STAGING_CMDS
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(@D) install-libs
	mkdir -p $(STAGING_DIR)/$(BRUNO_STAGING_PATH)
endef

define BRUNO_INSTALL_TARGET_CMDS
	$(call GENIMAGEVERSION,gfibertv)
	HOSTPYTHONPATH=$(HOST_PYTHONPATH) \
	PYTHONPATH=$(TARGET_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	HOSTDIR=$(HOST_DIR) \
	DESTDIR=$(TARGET_DIR) \
	BRUNO_PROD_BUILD=$(BR2_PACKAGE_GOOGLE_PROD) \
	BRUNO_ARCH=$(BRUNO_ARCH) \
	$(MAKE) -C $(@D) install

	# registercheck
	#TODO(apenwarr): do we actually need this for anything?
	mkdir -p $(TARGET_DIR)/home/test/
	cp -rf $(@D)/registercheck $(TARGET_DIR)/home/test/
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
