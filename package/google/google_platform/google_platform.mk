#############################################################
#
# Google Platform
#
#############################################################
GOOGLE_PLATFORM_SITE = null
GOOGLE_PLATFORM_SOURCE = null
GOOGLE_PLATFORM_VERSION = HEAD
GOOGLE_PLATFORM_INSTALL_TARGET = YES

define GOOGLE_PLATFORM_EXTRACT_CMDS
endef

$(eval $(call GENTARGETS))
