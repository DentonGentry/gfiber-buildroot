#############################################################
#
# webp (libraries needed by some apps)
#
#############################################################
WEBP_VERSION = 0.3.1
WEBP_SITE = https://webp.googlecode.com/files/
WEBP_SOURCE = libwebp-$(WEBP_VERSION).tar.gz
WEBP_INSTALL_STAGING = YES
WEBP_INSTALL_TARGET = YES

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
