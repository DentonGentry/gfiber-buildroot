#
# MINISSDPD
#

MINISSDPD_VERSION=1.2
MINISSDPD_SOURCE=minissdpd-$(MINISSDPD_VERSION).tar.gz
MINISSDPD_SITE=http://miniupnp.free.fr/files

MINISSDPD_ENV = \
	CC="$(TARGET_CC)" \
	STRIP="$(TARGET_STRIP)" \
	ARCH=$(BR2_ARCH) \
	VPATH=$(TARGET_DIR)/usr/lib \
	PREFIX=$(TARGET_DIR) \

define MINISSDPD_BUILD_CMDS
	$(MAKE) $(MINISSDPD_ENV) -C $(@D) all
endef

define MINISSDPD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/minissdpd $(TARGET_DIR)/usr/bin/minissdpd
	$(INSTALL) -m 755 -D package/minissdpd/S55ssdpd \
		$(TARGET_DIR)/etc/init.d/S55ssdpd
endef

$(eval $(call GENTARGETS))
