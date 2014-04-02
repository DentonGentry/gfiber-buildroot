#############################################################
#
# traceroute for Linux
#
#############################################################

TRACEROUTE_NEW_VERSION:=2.0.19
TRACEROUTE_NEW_SOURCE:=traceroute-$(TRACEROUTE_NEW_VERSION).tar.gz
TRACEROUTE_NEW_SITE:=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/traceroute/
TRACEROUTE_NEW_AUTORECONF:=NO
TRACEROUTE_NEW_INSTALL_STAGING:=NO
TRACEROUTE_NEW_INSTALL_TARGET:=YES

define TRACEROUTE_NEW_BUILD_CMDS
	$(MAKE) env=yes CROSS=$(TARGET_CROSS) -C $(@D)
endef

define TRACEROUTE_NEW_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/traceroute/traceroute \
		$(TARGET_DIR)/usr/bin/traceroute
endef

$(eval $(call GENTARGETS))
