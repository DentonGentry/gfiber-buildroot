BACKPORTS_CUSTOM_VERSION = custom
BACKPORTS_CUSTOM_SOURCE  = backports-$(BACKPORTS_CUSTOM_VERSION).tar
BACKPORTS_CUSTOM_SITE    = https://www.kernel.org/pub/linux/kernel/projects/backports/${BACKPORTS_CUSTOM_YYYY}/${BACKPORTS_CUSTOM_MM}/${BACKPORTS_CUSTOM_DD}
BACKPORTS_CUSTOM_DEPENDENCIES = linux

BACKPORTS_CUSTOM_MAKE_ENV = \
	$(TARGET_MAKE_ENV) \
	$(LINUX_MAKE_FLAGS) \
	KLIB_BUILD=$(LINUX_DIR) \
	KLIB=$(TARGET_DIR)

define BACKPORTS_CUSTOM_CONFIGURE_CMDS
	cp package/backports-custom/$(BR2_PACKAGE_BACKPORTS_CUSTOM_DEFCONFIG) $(@D)/.config
	$(BACKPORTS_CUSTOM_MAKE_ENV) $(MAKE) -C $(@D) olddefconfig
endef

define BACKPORTS_CUSTOM_BUILD_CMDS
	$(BACKPORTS_CUSTOM_MAKE_ENV) $(MAKE) -C $(@D)
endef

define BACKPORTS_CUSTOM_INSTALL_TARGET_CMDS
	$(BACKPORTS_CUSTOM_MAKE_ENV) $(MAKE) -C $(LINUX_DIR) M=$(@D) \
		INSTALL_MOD_DIR=backports \
		modules_install
endef

# Convenience wrappers:
# Do 'make backports-oldconfig' or 'make backports-menuconfig' from your out/
# directory to run 'make oldconfig' or 'make menuconfig' in the backports
# dir, as configured for your cross compiler and kernel.
backports-custom-oldconfig backports-custom-menuconfig: backports-custom-configure
	# intentionally don't use $(MAKE) here, to avoid $(LOGLINEAR)
	$(BACKPORTS_CUSTOM_MAKE_ENV) make -C $(BACKPORTS_CUSTOM_DIR) \
		$(patsubst backports-custom-%,%,$@) </dev/tty >/dev/tty 2>&1

# Same as above, but for 'make savedefconfig'.  Also copies the new defconfig
# into the defconfig file for this platform.
backports-custom-savedefconfig:
	$(BACKPORTS_CUSTOM_MAKE_ENV) $(MAKE) -C $(BACKPORTS_CUSTOM_DIR) savedefconfig
	cp $(BACKPORTS_CUSTOM_DIR)/defconfig \
		package/backports-custom/$(BR2_PACKAGE_BACKPORTS_CUSTOM_DEFCONFIG)

$(eval $(call GENTARGETS))
