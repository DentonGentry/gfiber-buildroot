# Until we add a proper java package
GOOGLE_JAVA_HOME=/usr/local/buildtools/java/jdk

# TODO(apenwarr): Merge all other packages that use vendor/google/platform.
#  Right now we have several buildroot packages that use the same source
#  tree but build different parts of it with different options.  That's
#  very error prone and also wastes time at checkout.  It also may result
#  in multiple packages installing the same target files at once.
GOOGLE_PLATFORM_SITE=repo://vendor/google/platform
GOOGLE_PLATFORM_INSTALL_STAGING=YES
GOOGLE_PLATFORM_INSTALL_TARGET=YES
GOOGLE_PLATFORM_STAGING_PATH=usr/lib/bruno
GOOGLE_PLATFORM_DEPENDENCIES=\
	host-python-crypto \
	host-py-mox \
	python \
	python-setuptools \
	host-python-setuptools \
	protobuf \
	libcurl \

HOST_GOOGLE_PLATFORM_DEPENDENCIES += host-gtest host-libcurl

ifeq ($(BR2_PACKAGE_GOOGLE_PLATFORM_HNVRAM),y)
GOOGLE_PLATFORM_DEPENDENCIES += humax_misc
HOST_GOOGLE_PLATFORM_DEPENDENCIES += host-humax_misc
endif


ifeq ($(BR2_PACKAGE_AVAHI),y)
ifeq ($(BR2_PACKAGE_DBUS),y)
BUILD_DNSSD=y
GOOGLE_PLATFORM_DEPENDENCIES += avahi
endif
endif

ifeq      ($(BR2_arm),y)
GOOGLE_PLATFORM_ARCH   := arm
else ifeq ($(BR2_mips),y)
GOOGLE_PLATFORM_ARCH   := mips
else ifeq ($(BR2_mipsel),y)
GOOGLE_PLATFORM_ARCH   := mips
else ifeq ($(BR2_i386),y)
GOOGLE_PLATFORM_ARCH   := i386
endif

# TODO(apenwarr): postbuild.sh should use flags instead of platform_*.
#  BR2_TARGET_GOOGLE_PLATFORM is only used in postbuild.sh to choose which
#  variants of a few files it should use.  To allow for more flexibility
#  in our device configurations, it would be better to change that script
#  to support multiple flags (is it a storage box? is it also a network box?)
#  in that script instead of making one "platform" per flag combination.
ifeq      ($(BR2_PACKAGE_GOOGLE_STORAGE_BOX),y)
BR2_TARGET_GOOGLE_PLATFORM := gfibertv
BUILD_LOGUPLOAD=y
else ifeq ($(BR2_PACKAGE_GOOGLE_FIBER_JACK),y)
BR2_TARGET_GOOGLE_PLATFORM := gfiberlt
else ifeq ($(BR2_PACKAGE_GOOGLE_NETWORK_BOX),y)
BR2_TARGET_GOOGLE_PLATFORM := gfibertv
BUILD_LOGUPLOAD=y
else ifeq ($(BR2_PACKAGE_GOOGLE_SPACECAST),y)
BR2_TARGET_GOOGLE_PLATFORM := gfibersc
BUILD_LOGUPLOAD=y
endif

define GOOGLE_PLATFORM_PERMISSIONS
/var/media				d 0555	200 0 - - - - -
/chroot/samba/var/media	d 0555	200 0 - - - - -
/chroot/samba/tmp		d 0555	200 200 - - - - -
endef

GPLAT_MAKE = \
	HOSTDIR=$(HOST_DIR) \
	DESTDIR=$(TARGET_DIR) \
	HOSTPYTHONPATH=$(HOST_PYTHONPATH) \
	TARGETPYTHONPATH=$(TARGET_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	CROSS_COMPILE=$(TARGET_CROSS) \
	BRUNO_PROD_BUILD=$(BR2_PACKAGE_GOOGLE_PROD) \
	CC="$(TARGET_CC) $(TARGET_CFLAGS)" \
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(@D)/base:$(STAGING_DIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	BRUNO_ARCH=$(GOOGLE_PLATFORM_ARCH) \
	BR2_PACKAGE_BCM_NEXUS=$(BR2_PACKAGE_BCM_NEXUS) \
	BR2_PACKAGE_MINDSPEED_DRIVERS=$(BR2_PACKAGE_MINDSPEED_DRIVERS) \
	BR2_TARGET_GENERIC_PLATFORM_NAME=$(BR2_TARGET_GENERIC_PLATFORM_NAME) \
	HUMAX_UPGRADE_DIR=$(HUMAX_MISC_DIR)/libupgrade \
	BUILD_HNVRAM=$(BR2_PACKAGE_GOOGLE_PLATFORM_HNVRAM) \
	BUILD_SSDP=$(BR2_PACKAGE_MINIUPNPD) \
	BUILD_DNSSD=$(BUILD_DNSSD) \
	BUILD_LOGUPLOAD=$(BUILD_LOGUPLOAD) \
	BR2_TARGET_GOOGLE_PLATFORM=$(BR2_TARGET_GOOGLE_PLATFORM) \
	$(MAKE)

HOST_GPLAT_MAKE = \
	HOSTDIR=$(HOST_DIR) \
	DESTDIR=$(HOST_DIR) \
	EXTRACFLAGS="$(HOST_CFLAGS)" \
	EXTRALDFLAGS="$(HOST_LDFLAGS)" \
	BRUNO_ARCH=i386 \
	HUMAX_UPGRADE_DIR=$(HOST_HUMAX_MISC_DIR)/libupgrade \
	BUILD_HNVRAM=$(BR2_PACKAGE_GOOGLE_PLATFORM_HNVRAM) \
	BUILD_LOGUPLOAD=$(BUILD_LOGUPLOAD) \
	$(MAKE)

define GOOGLE_PLATFORM_BUILD_CMDS
	$(GPLAT_MAKE) -C $(@D)
endef

define GOOGLE_PLATFORM_TEST_CMDS
	PYTHONPATH=$(HOST_PYTHONPATH) $(GPLAT_MAKE) \
			   BUILD_HNVRAM=n BUILD_LOGUPLOAD=n \
			   -C $(@D) test
endef

define HOST_GOOGLE_PLATFORM_TEST_CMDS
	$(if $(BR2_PACKAGE_GOOGLE_PLATFORM_HNVRAM),PYTHONPATH=$(HOST_PYTHONPATH) $(HOST_GPLAT_MAKE) -C $(@D) hnvram/test)
	$(if $(BUILD_LOGUPLOAD),$(HOST_GPLAT_MAKE) -C $(@D) logupload/client/test)
endef

define GOOGLE_PLATFORM_INSTALL_STAGING_CMDS
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(@D) install-libs
	mkdir -p $(STAGING_DIR)/$(GOOGLE_PLATFORM_STAGING_PATH)
endef

define GOOGLE_PLATFORM_INSTALL_TARGET_CMDS
	$(GPLAT_MAKE) -C $(@D) install

	# registercheck
	#TODO(apenwarr): do we actually need this for anything?
	mkdir -p $(TARGET_DIR)/home/test/
	cp -rf $(@D)/registercheck $(TARGET_DIR)/home/test/
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
