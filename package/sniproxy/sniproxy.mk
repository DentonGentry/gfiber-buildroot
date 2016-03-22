############################################################
#
# sniproxy
#
############################################################

SNIPROXY_VERSION = 0.4.0
SNIPROXY_SITE = https://github.com/dlundquist/sniproxy/tarball/$(SNIPROXY_VERSION)
SNIPROXY_LICENSE = BSD-2c

SNIPROXY_AUTORECONF = YES
SNIPROXY_DEPENDENCIES += host-pkg-config libev pcre udns

SNIPROXY_INSTALL_STAGING = NO
SNIPROXY_INSTALL_TARGET = YES

define SNIPROXY_INSTALL_CONFIG
	$(INSTALL) -m 0755 -D package/sniproxy/sniproxy.conf $(TARGET_DIR)/etc
	$(INSTALL) -m 0755 -D package/sniproxy/S92sniproxy $(TARGET_DIR)/etc/init.d
endef

SNIPROXY_POST_INSTALL_TARGET_HOOKS += SNIPROXY_INSTALL_CONFIG

$(eval $(call AUTOTARGETS))
