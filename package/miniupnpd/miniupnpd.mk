#
# MINIUPNPD
#

MINIUPNPD_VERSION=1.8
MINIUPNPD_SOURCE=miniupnpd-$(MINIUPNPD_VERSION).tar.gz
MINIUPNPD_SITE=http://miniupnp.free.fr/files
MINIUPNPD_DEPENDENCIES = iptables libnfnetlink

MINIUPNPD_ENV = \
	CONFIG_OPTIONS="--ipv6" \
	CC="$(TARGET_CC)" \
	STRIP="$(TARGET_STRIP)" \
	ARCH=$(BR2_ARCH) \
	VPATH=$(TARGET_DIR)/usr/lib \
	PREFIX=$(TARGET_DIR) \
	IPTABLESPATH=$(IPTABLES_DIR) \
	OS_NAME="Google Fiber"

define MINIUPNPD_BUILD_CMDS
	$(MAKE1) -f Makefile.linux $(MINIUPNPD_ENV) -C $(@D) all
endef

define MINIUPNPD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/miniupnpd $(TARGET_DIR)/usr/bin/miniupnpd; \
	$(INSTALL) -m 755 -D package/miniupnpd/S80upnpd \
		$(TARGET_DIR)/etc/init.d/S80upnpd
endef

$(eval $(call GENTARGETS))
