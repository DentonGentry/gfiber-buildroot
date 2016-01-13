#############################################################
#
# libev
#
#############################################################
LIBEV_VERSION = 4.22
LIBEV_SOURCE = libev-$(LIBEV_VERSION).tar.gz
LIBEV_SITE = http://dist.schmorp.de/libev/Attic/
LIBEV_INSTALL_STAGING = YES

$(eval $(call AUTOTARGETS))
