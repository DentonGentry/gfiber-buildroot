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
	host-py-mock \
	python \
	python-setuptools \
	host-python-setuptools \
	libcares \
	libcurl \
        libjsoncpp \
	host-libcares \
	host-libcurl \
        host-libjsoncpp

HOST_GOOGLE_PLATFORM_DEPENDENCIES=\
	$(GOOGLE_PLATFORM_DEPENDENCIES) \
	host-gtest \
	host-libcurl \
	host-libcares \
	host-protobuf \
	host-libpcap

GOOGLE_PLATFORM_TARGET_CFLAGS=-I$(STAGING_DIR)/usr/include/python2.7
GOOGLE_PLATFORM_HOST_CFLAGS=-isystem $(HOST_DIR)/usr/include

ifeq ($(BR2_PACKAGE_GOOGLE_PLATFORM_HNVRAM),y)
GOOGLE_PLATFORM_DEPENDENCIES += humax_misc
HOST_GOOGLE_PLATFORM_DEPENDENCIES += host-humax_misc
endif

ifeq ($(BR2_PACKAGE_AVAHI),y)
ifeq ($(BR2_PACKAGE_DBUS),y)
BUILD_DNSSD=y
GOOGLE_PLATFORM_DEPENDENCIES += avahi
HOST_GOOGLE_PLATFORM_DEPENDENCIES += host-avahi
endif
endif

ifeq ($(BR2_PACKAGE_BLUEZ_UTILS),y)
ifeq ($(BR2_PACKAGE_UTIL_LINUX),y)
BUILD_IBEACON=y
GOOGLE_PLATFORM_DEPENDENCIES += bluez_utils util-linux
HOST_GOOGLE_PLATFORM_DEPENDENCIES += host-bluez_utils host-util-linux
endif
endif

ifeq ($(BR2_PACKAGE_PROTOBUF),y)
BUILD_STATUTILS=y
GOOGLE_PLATFORM_DEPENDENCIES += protobuf
endif

ifeq ($(BR2_PACKAGE_DBUS),y)
GOOGLE_PLATFORM_DEPENDENCIES += dbus
endif

ifeq ($(BR2_PACKAGE_LVM2),y)
GOOGLE_PLATFORM_DEPENDENCIES += lvm2
HOST_GOOGLE_PLATFORM_DEPENDENCIES += host-lvm2
endif

ifeq ($(BR2_PACKAGE_LIBNL),y)
BUILD_WIFIUTILS=y
GOOGLE_PLATFORM_DEPENDENCIES += libnl libglib2
HOST_GOOGLE_PLATFORM_DEPENDENCIES += host-libnl host-libglib2
GOOGLE_PLATFORM_TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl3
GOOGLE_PLATFORM_HOST_CFLAGS += -I$(HOST_DIR)/usr/include/libnl3
GOOGLE_PLATFORM_TARGET_CFLAGS += -I$(BACKPORTS_CUSTOM_DIR)/include/uapi
GOOGLE_PLATFORM_TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/glib-2.0 -I$(STAGING_DIR)/usr/lib/glib-2.0/include
GOOGLE_PLATFORM_HOST_CFLAGS += -I$(HOST_DIR)/usr/include/glib-2.0 -I$(HOST_DIR)/usr/lib/glib-2.0/include
ifeq ($(BR2_PACKAGE_BACKPORTS_CUSTOM),y)
GOOGLE_PLATFORM_TARGET_CFLAGS += -DNL80211_RECENT_FIELDS
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

ifeq ($(BR2_PACKAGE_GOOGLE_PLATFORM_WAVEGUIDE),y)
BUILD_WAVEGUIDE=y
endif

ifeq ($(BR2_PACKAGE_GOOGLE_PLATFORM_DVBUTILS),y)
BUILD_DVBUTILS=y
endif

ifeq ($(BR2_PACKAGE_GOOGLE_PLATFORM_SYSMGR),y)
BUILD_SYSMGR=y
endif

ifeq ($(BR2_PACKAGE_GOOGLE_PLATFORM_CRYPTDEV),y)
BUILD_CRYPTDEV=y
endif

ifeq ($(BR2_PACKAGE_GOOGLE_PLATFORM_JSONPOLL),y)
BUILD_JSONPOLL=y
endif

ifneq ($(BR2_PACKAGE_GOOGLE_FIBER_JACK),y)
# fiber jack kernel is too old for the new-style loguploader for now
BUILD_LOGUPLOAD=y
endif

BUILD_SPEEDTEST=y
ifeq ($(BR2_PACKAGE_GOOGLE_FIBER_JACK),y)
# Fiber Jack toolchain doesn't support -std=c++11
BUILD_SPEEDTEST=n
else ifeq ($(BR2_TARGET_GENERIC_PLATFORM_NAME),"gfch100")
# Avanta toolchain doesn't support -std=c++11
BUILD_SPEEDTEST=n
endif

ifeq ($(BR2_PACKAGE_GOOGLE_PLATFORM_CONNECTION_MANAGER),y)
BUILD_CONMAN=y
GOOGLE_PLATFORM_DEPENDENCIES += py-inotify py-wpactrl
HOST_GOOGLE_PLATFORM_DEPENDENCIES += host-py-inotify
endif

PUB_KEY=gfiber

ifeq ($(BR2_TARGET_GENERIC_PLATFORM_NAME),"gfsc100")
PUB_KEY=gfibersc
endif

ifneq ($(BR2_PACKAGE_GOOGLE_KEY_SUFFIX),"")
PUB_KEY := $(PUB_KEY)-$(patsubst "%",%,$(BR2_PACKAGE_GOOGLE_KEY_SUFFIX))
endif

define GOOGLE_PLATFORM_PERMISSIONS
/var/media				d 0555	200 0 - - - - -
/chroot/samba/var/media	d 0555	200 0 - - - - -
/chroot/samba/tmp		d 0555	200 200 - - - - -
endef

GPLAT_BASEMAKE = \
	HOSTDIR=$(HOST_DIR) \
	HOSTPYTHONPATH=$(HOST_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	BRUNO_PROD_BUILD=$(BR2_PACKAGE_GOOGLE_PROD) \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(@D)/base:$(STAGING_DIR)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	BR2_PACKAGE_BCM_NEXUS=$(BR2_PACKAGE_BCM_NEXUS) \
	BR2_PACKAGE_MINDSPEED_DRIVERS=$(BR2_PACKAGE_MINDSPEED_DRIVERS) \
	BR2_TARGET_GENERIC_PLATFORM_NAME=$(BR2_TARGET_GENERIC_PLATFORM_NAME) \
	BUILD_HNVRAM=$(BR2_PACKAGE_GOOGLE_PLATFORM_HNVRAM) \
	BUILD_SSDP=$(BR2_PACKAGE_MINIUPNPD) \
	BUILD_DNSSD=$(BUILD_DNSSD) \
	BUILD_LOGUPLOAD=$(BUILD_LOGUPLOAD) \
	BUILD_IBEACON=$(BUILD_IBEACON) \
	BUILD_WAVEGUIDE=$(BUILD_WAVEGUIDE) \
	BUILD_DVBUTILS=$(BUILD_DVBUTILS) \
	BUILD_SYSMGR=$(BUILD_SYSMGR) \
	BUILD_STATUTILS=$(BUILD_STATUTILS) \
	BUILD_CRYPTDEV=$(BUILD_CRYPTDEV) \
	BUILD_SIGNING=y \
	BUILD_WIFIUTILS=$(BUILD_WIFIUTILS) \
	BUILD_SPEEDTEST=$(BUILD_SPEEDTEST) \
	BUILD_JSONPOLL=$(BUILD_JSONPOLL) \
	BUILD_CONMAN=$(BUILD_CONMAN)

GPLAT_MAKE = \
	$(GPLAT_BASEMAKE) \
	DESTDIR=$(TARGET_DIR) \
	TARGETPYTHONPATH=$(TARGET_PYTHONPATH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	CC="$(TARGET_CC)" \
	HOST_CC="$(HOSTCC)" \
	EXTRACFLAGS="$(TARGET_CFLAGS) $(GOOGLE_PLATFORM_TARGET_CFLAGS)" \
	EXTRACXXFLAGS="$(TARGET_CXXFLAGS) $(GOOGLE_PLATFORM_TARGET_CFLAGS)" \
	LDSHARED="$(TARGET_CC) -shared" \
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	BRUNO_ARCH=$(GOOGLE_PLATFORM_ARCH) \
	HUMAX_UPGRADE_DIR=$(HUMAX_MISC_DIR)/libupgrade \
	$(MAKE)

HOST_GPLAT_MAKE = \
	$(GPLAT_BASEMAKE) \
	HOSTDIR=$(HOST_DIR) \
	DESTDIR=$(HOST_DIR) \
	HOST_CC="$(HOSTCC)" \
	HOST_CXX="$(HOSTCXX)" \
	EXTRACFLAGS="$(HOST_CFLAGS) -L$(HOST_DIR)/usr/lib $(GOOGLE_PLATFORM_HOST_CFLAGS)" \
	EXTRACXXFLAGS="$(HOST_CXXFLAGS) -L$(HOST_DIR)/usr/lib $(GOOGLE_PLATFORM_HOST_CFLAGS)" \
	EXTRALDFLAGS="$(HOST_LDFLAGS) -L$(HOST_DIR)/usr/lib" \
	BRUNO_ARCH=i386 \
	RUN_HOST_TESTS=y \
	HUMAX_UPGRADE_DIR=$(HOST_HUMAX_MISC_DIR)/libupgrade \
	$(MAKE)

define HOST_GOOGLE_PLATFORM_BUILD_CMDS
	$(HOST_GPLAT_MAKE) -C $(@D)
endef

define GOOGLE_PLATFORM_BUILD_CMDS
	$(GPLAT_MAKE) -C $(@D)
endef

define HOST_GOOGLE_PLATFORM_TEST_CMDS
	$(HOST_GPLAT_MAKE) -C $(@D) test
endef

define HOST_GOOGLE_PLATFORM_INSTALL_CMDS
	$(HOST_GPLAT_MAKE) -C $(@D) install-libs
endef

define GOOGLE_PLATFORM_INSTALL_STAGING_CMDS
	$(GPLAT_MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install-libs
endef

define GOOGLE_PLATFORM_INSTALL_TARGET_CMDS
	$(GPLAT_MAKE) -C $(@D) install

	$(if $(BR2_PACKAGE_GOOGLE_PLATFORM_LOGUPLOAD),$(INSTALL) -m 0755 -D package/google/google_platform/S95uploadlog $(TARGET_DIR)/etc/init.d/)
	$(if $(BR2_PACKAGE_GOOGLE_PLATFORM_WAVEGUIDE),$(INSTALL) -m 0755 -D package/google/google_platform/S50waveguide $(TARGET_DIR)/etc/init.d/)
	$(INSTALL) -m 0755 -D package/google/google_platform/S52conman $(TARGET_DIR)/etc/init.d/
	$(if $(BR2_PACKAGE_GOOGLE_PLATFORM_SYSMGR),$(INSTALL) -m 0755 -D package/google/google_platform/S04sysmgr $(TARGET_DIR)/etc/init.d/)
	$(if $(BR2_HAVE_EXTRA_CLEANUP),$(INSTALL) -m 0755 -D package/google/google_platform/S99xxemergency $(TARGET_DIR)/etc/init.d/)
	$(INSTALL) -m 0755 -D -T package/google/google_platform/gfiber_public.der/$(PUB_KEY) $(TARGET_DIR)/etc/gfiber_public.der

	# registercheck
	#TODO(apenwarr): do we actually need this for anything?
	mkdir -p $(TARGET_DIR)/home/test/
	cp -rf $(@D)/registercheck $(TARGET_DIR)/home/test/
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
