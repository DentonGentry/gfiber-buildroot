#############################################################
#
# bluez_utils
#
#############################################################

BLUEZ_UTILS_SITE = repo://vendor/opensource/bluez
BLUEZ_UTILS_DEPENDENCIES = dbus libglib2 readline
BLUEZ_UTILS_INSTALL_STAGING = YES
BLUEZ_UTILS_CONF_OPT = \
	--prefix=/usr \
	--libexecdir=/usr/bin \
	--localstatedir=/user/bluez \
	--sysconfdir=/tmp/bluez/etc \
	--enable-tools \
	--enable-library \
	--disable-cups \
	--disable-obex \
	--disable-client \
	--enable-experimental \
	--enable-attrib \
	--enable-test \
	--disable-udev \
	--disable-systemd
HOST_BLUEZ_UTILS_CONF_OPT = $(BLUEZ_UTILS_CONF_OPT) \
	--prefix=$(HOST_DIR)/usr \
	--libexecdir=$(HOST_DIR)/usr/bin \
	--localstatedir=$(HOST_DIR)/user/bluez

BLUEZ_UTILS_AUTORECONF = YES
HOST_BLUEZ_UTILS_AUTORECONF = YES

ifeq ($(BR2_PACKAGE_PYTHON),y)
BLUEZ_UTILS_DEPENDENCIES += python
endif

# BlueZ 3.x compatibility
ifeq ($(BR2_PACKAGE_BLUEZ_UTILS_COMPAT),y)
BLUEZ_UTILS_CONF_OPT +=	\
	--enable-hidd	\
	--enable-pand	\
	--enable-sdp	\
	--enable-dund
endif

# audio support
ifeq ($(BR2_PACKAGE_BLUEZ_UTILS_AUDIO),y)
BLUEZ_UTILS_DEPENDENCIES +=	\
	alsa-lib		\
	libsndfile
BLUEZ_UTILS_CONF_OPT +=	\
	--enable-alsa	\
	--enable-audio
else
BLUEZ_UTILS_CONF_OPT +=	\
	--disable-alsa	\
	--disable-audio
endif

# USB support
ifeq ($(BR2_PACKAGE_BLUEZ_UTILS_USB),y)
BLUEZ_UTILS_DEPENDENCIES += libusb
BLUEZ_UTILS_CONF_OPT +=	\
	--enable-usb
else
BLUEZ_UTILS_CONF_OPT +=	\
	--disable-usb
endif

define BLUEZ_UTILS_TARGET_TWEAKS
	mv $(TARGET_DIR)/usr/lib/bluez/test/unplug-GFRM100 $(TARGET_DIR)/usr/bin/
	mv $(TARGET_DIR)/usr/lib/bluez/test/* $(TARGET_DIR)/usr/bin/bluetooth/
	rm -rf $(TARGET_DIR)/usr/lib/bluez/
	rm -rf $(TARGET_DIR)/user/bluez/
	$(INSTALL) -m 0755 -D package/bluez_utils/S31bluez $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 0755 -D package/bluez_utils/S55btlast $(TARGET_DIR)/etc/init.d
endef

BLUEZ_UTILS_POST_INSTALL_TARGET_HOOKS += BLUEZ_UTILS_TARGET_TWEAKS

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
