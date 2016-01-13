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

$(eval $(call AUTOTARGETS))
