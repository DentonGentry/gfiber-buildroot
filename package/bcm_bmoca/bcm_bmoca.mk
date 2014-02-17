BCM_BMOCA_SITE=repo://vendor/broadcom/bmoca
BCM_BMOCA_INSTALL_TARGET=YES
BCM_BMOCA_DEPENDENCIES=linux

BCM_BMOCA_MAKE_ENV = \
	$(TARGET_MAKE_ENV) \
	$(LINUX_MAKE_FLAGS) \
	KLIB_BUILD=$(LINUX_DIR) \
	KLIB=$(TARGET_DIR)

define BCM_BMOCA_BUILD_CMDS
	# Note: we build the moca2 kernel module for moca v1 and v2.
	# It's compatible with both userspace daemons.
	$(BCM_BMOCA_MAKE_ENV) $(MAKE) \
		EXTRA_CFLAGS="-I$(@D)" \
		-C $(LINUX_DIR) M=$(@D)
endef

define BCM_BMOCA_INSTALL_TARGET_CMDS
	$(BCM_BMOCA_MAKE_ENV) $(MAKE) \
		-C $(LINUX_DIR) M=$(@D) \
		INSTALL_MOD_DIR=bmoca \
		modules_install
endef

$(eval $(call GENTARGETS))
