#############################################################
#
# vconfig
#
#############################################################
VCONFIG_VERSION:=1.9
VCONFIG_SOURCE:=vlan.$(VCONFIG_VERSION).tar.gz
VCONFIG_SITE:=http://www.candelatech.com/~greear/vlan
VCONFIG_INSTALL_TARGET = YES

define VCONFIG_CONFIGURE_CMDS
	# vconfig tarball helpfully includes x86 binaries.
	rm -f $(@D)/vconfig $(@D)/vconfig.o $(@D)/macvlan_config
endef

define VCONFIG_BUILD_CMDS
echo $(TARGET_CC)
	$(MAKE) -C $(@D) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)" STRIP="$(TARGET_STRIP)" vconfig
endef

define VCONFIG_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin; \
	cp -f $(@D)/vconfig $(TARGET_DIR)/usr/bin
endef

$(eval $(call AUTOTARGETS))
