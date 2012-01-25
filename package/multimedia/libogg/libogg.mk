#############################################################
#
# libogg
#
#############################################################
LIBOGG_VERSION = 1.3.0
LIBOGG_SOURCE = libogg-$(LIBOGG_VERSION).tar.gz
LIBOGG_SITE = http://downloads.xiph.org/releases/ogg
LIBOGG_INSTALL_STAGING = YES

LIBOGG_DEPENDENCIES = host-pkg-config

$(eval $(call AUTOTARGETS))
