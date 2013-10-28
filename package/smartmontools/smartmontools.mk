#############################################################
#
# smartmontools
#
#############################################################

SMARTMONTOOLS_VERSION = 5.41
SMARTMONTOOLS_SITE = http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/smartmontools

define SMARTMONTOOLS_INSTALL_TARGET_CMDS
  $(INSTALL) -D -m 0755 $(@D)/smartctl $(TARGET_DIR)/usr/sbin/smartctl.real
endef

$(eval $(call AUTOTARGETS))
