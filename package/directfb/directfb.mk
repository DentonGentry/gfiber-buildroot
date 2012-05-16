#############################################################
#
# directfb
#
#############################################################
DIRECTFB_VERSION_MAJOR = 1.4
DIRECTFB_VERSION = $(DIRECTFB_VERSION_MAJOR).15
DIRECTFB_SITE = http://www.directfb.org/downloads/Core/DirectFB-$(DIRECTFB_VERSION_MAJOR)
DIRECTFB_SOURCE = DirectFB-$(DIRECTFB_VERSION).tar.gz

DIRECTFB_DEPENDENCIES = bcm_directfb
DIRECTFB_INSTALL_STAGING = NO
DIRECTFB_INSTALL_TARGET = NO

$(eval $(call GENTARGETS))

