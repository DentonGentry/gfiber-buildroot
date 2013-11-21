#############################################################
#
# libmng (Multiple-image Network Graphic library)
#
#############################################################

LIBMNG_VERSION = 2.0.2
LIBMNG_SITE = http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/libmng
LIBMNG_SOURCE = libmng-$(LIBMNG_VERSION).tar.gz
LIBMNG_INSTALL_STAGING = YES
LIBMNG_DEPENDENCIES = host-pkg-config jpeg zlib

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
