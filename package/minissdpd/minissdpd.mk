#
# MINISSDPD
#

MINISSDPD_VERSION=1.2
MINISSDPD_SOURCE=minissdpd-$(MINISSDPD_VERSION).tar.gz
MINISSDPD_SITE=http://miniupnp.free.fr/files/download.php?file=
MINIUPNPD_SITE_METHOD=null

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
endef

$(DL_DIR)/$(MINIUPNPD_SOURCE):
	$(WGET) -O $@ $(call qstrip,$(MINIUPNPD_SITE))$(MINIUPNPD_SOURCE)

$(eval $(call GENTARGETS))
