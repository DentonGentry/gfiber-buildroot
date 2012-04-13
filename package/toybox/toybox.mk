#
# toybox, a busybox replacement
#

TOYBOX_VERSION=0.2.1
TOYBOX_SOURCE=toybox-$(TOYBOX_VERSION).tar.bz2
TOYBOX_SITE=http://landley.net/toybox/downloads

# toybox utilities take precedence over the same ones in toolbox
ifeq ($(BR2_PACKAGE_TOOLBOX),y)
TOYBOX_DEPENDENCIES+=toolbox
endif

TOYBOX_BUILD_CONFIG=$(BR2_PACKAGE_TOYBOX_CONFIG)

define TOYBOX_CONFIGURE_CMDS
	cp $(TOYBOX_BUILD_CONFIG) $(@D)/.config
endef

define TOYBOX_BUILD_CMDS
	$(MAKE) -C $(@D) CFLAGS="--static" CC=gcc CROSS_COMPILE="$(TARGET_CROSS)"
endef

define TOYBOX_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D) PREFIX=$(TARGET_DIR) install
endef

$(eval $(call GENTARGETS, package, toybox))
