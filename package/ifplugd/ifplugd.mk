#############################################################
#
# ifplugd
#
#############################################################

IFPLUGD_VERSION = 0.28
IFPLUGD_SITE = http://0pointer.de/lennart/projects/ifplugd
IFPLUGD_AUTORECONF = YES
# install-strip unconditionally overwrites $(TARGET_DIR)/etc/ifplugd/ifplugd.*
IFPLUGD_INSTALL_TARGET_OPT = DESTDIR=$(TARGET_DIR) install-exec
IFPLUGD_CONF_OPT = --disable-lynx
IFPLUGD_DEPENDENCIES = libdaemon

# Prefer big ifplugd
ifeq ($(BR2_PACKAGE_BUSYBOX),y)
	IFPLUGD_DEPENDENCIES += busybox
endif

define IFPLUGD_INSTALL_FIXUP
	$(INSTALL) -m 755 -D package/ifplugd/S80ifplugd \
		$(TARGET_DIR)/etc/init.d/S80ifplugd
	$(INSTALL) -d $(TARGET_DIR)/etc/ifplugd
	$(INSTALL) -m 755 -D package/ifplugd/ifplugd.action \
		$(TARGET_DIR)/etc/ifplugd/ifplugd.action
endef

IFPLUGD_POST_INSTALL_TARGET_HOOKS += IFPLUGD_INSTALL_FIXUP

$(eval $(call AUTOTARGETS))
