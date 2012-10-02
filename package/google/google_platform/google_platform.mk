#############################################################
#
# Google Platform
#
#############################################################
GOOGLE_PLATFORM_SITE = null
GOOGLE_PLATFORM_SOURCE = null
GOOGLE_PLATFORM_VERSION = HEAD
GOOGLE_PLATFORM_INSTALL_TARGET = YES
GOOGLE_PLATFORM_DEPENDENCIES = linux

define GOOGLE_PLATFORM_EXTRACT_CMDS
endef

define GOOGLE_PLATFORM_INSTALL_TARGET_CMDS
	support/scripts/postproc_skel.sh $(TARGET_SKELETON) $(TARGET_DIR) $(BR2_TARGET_GOOGLE_PLATFORM)
endef

$(eval $(call GENTARGETS))
