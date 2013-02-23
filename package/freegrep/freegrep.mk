#############################################################
#
# grep
#
#############################################################

FREEGREP_VERSION = 1.1
FREEGREP_SITE = https://github.com/downloads/howardjp/freegrep
FREEGREP_SOURCE = grep-$(FREEGREP_VERSION).tar.bz2

# Full grep preferred over busybox grep
ifeq ($(BR2_PACKAGE_BUSYBOX),y)
FREEGREP_DEPENDENCIES += busybox
endif

define FREEGREP_BUILD_CMDS
	$(MAKE) -C $(@D) CC="$(TARGET_CC) $(TARGET_CFLAGS)"
endef

define FREEGREP_INSTALL_TARGET_CMDS
	install $(@D)/grep $(TARGET_DIR)/bin/grep
endef

$(eval $(call GENTARGETS))
