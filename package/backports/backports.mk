BACKPORTS_YYYY    = 2014
BACKPORTS_MM      = 04
BACKPORTS_DD      = 17
BACKPORTS_VERSION = ${BACKPORTS_YYYY}${BACKPORTS_MM}${BACKPORTS_DD}
BACKPORTS_SOURCE  = backports-$(BACKPORTS_VERSION).tar.gz
BACKPORTS_SITE    = https://www.kernel.org/pub/linux/kernel/projects/backports/${BACKPORTS_YYYY}/${BACKPORTS_MM}/${BACKPORTS_DD}
BACKPORTS_DEPENDENCIES = linux

BACKPORTS_MAKE_ENV = \
	$(TARGET_MAKE_ENV) \
	$(LINUX_MAKE_FLAGS) \
	KLIB_BUILD=$(LINUX_DIR) \
	KLIB=$(TARGET_DIR)

define BACKPORTS_CONFIGURE_CMDS
	cp package/backports/$(BR2_PACKAGE_BACKPORTS_DEFCONFIG) $(@D)/.config
	$(BACKPORTS_MAKE_ENV) $(MAKE) -C $(@D) olddefconfig
endef

define BACKPORTS_BUILD_CMDS
	$(BACKPORTS_MAKE_ENV) $(MAKE) -C $(@D)
endef

define BACKPORTS_INSTALL_TARGET_CMDS
	$(BACKPORTS_MAKE_ENV) $(MAKE) -C $(LINUX_DIR) M=$(@D) \
		INSTALL_MOD_DIR=backports \
		modules_install
endef

# Convenience wrappers:
# Do 'make backports-oldconfig' or 'make backports-menuconfig' from your out/
# directory to run 'make oldconfig' or 'make menuconfig' in the backports
# dir, as configured for your cross compiler and kernel.
backports-oldconfig backports-menuconfig: backports-configure
	# intentionally don't use $(MAKE) here, to avoid $(LOGLINEAR)
	$(BACKPORTS_MAKE_ENV) make -C $(BACKPORTS_DIR) \
		$(patsubst backports-%,%,$@) </dev/tty >/dev/tty 2>&1

# Same as above, but for 'make savedefconfig'.  Also copies the new defconfig
# into the defconfig file for this platform.
backports-savedefconfig:
	$(BACKPORTS_MAKE_ENV) $(MAKE) -C $(BACKPORTS_DIR) savedefconfig
	cp $(BACKPORTS_DIR)/defconfig \
		package/backports/$(BR2_PACKAGE_BACKPORTS_DEFCONFIG)

$(eval $(call GENTARGETS))
