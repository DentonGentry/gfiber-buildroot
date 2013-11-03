BACKPORTS_VERSION = 3.11.6
BACKPORTS_SOURCE  = backports-$(BACKPORTS_VERSION)-1.tar.bz2
BACKPORTS_SITE    = http://www.kernel.org/pub/linux/kernel/projects/backports/stable/v$(BACKPORTS_VERSION)
BACKPORTS_DEPENDENCIES = linux

BACKPORTS_MAKE_ENV = \
	$(TARGET_MAKE_ENV) \
	$(LINUX_MAKE_FLAGS) \
	KLIB_BUILD=$(LINUX_DIR) \
	KLIB=$(TARGET_DIR)

define BACKPORTS_CONFIGURE_CMDS
	cp package/backports/config $(@D)/.config
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

$(eval $(call GENTARGETS))
