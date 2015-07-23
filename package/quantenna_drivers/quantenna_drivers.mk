QUANTENNA_DRIVERS_SITE=repo://vendor/quantenna/drivers
QUANTENNA_DRIVERS_DEPENDENCIES=linux

QUANTENNA_DRIVERS_MAKE_ENV = KERNEL_ARCH=$(KERNEL_ARCH) \
                             LINUX_DIR=$(LINUX_DIR) \
                             TARGET_CROSS=$(TARGET_CROSS) \
                             TARGET_DIR=$(TARGET_DIR)

define QUANTENNA_DRIVERS_BUILD_CMDS
	$(QUANTENNA_DRIVERS_MAKE_ENV) $(MAKE) -C $(@D)
endef

define QUANTENNA_DRIVERS_INSTALL_TARGET_CMDS
	$(QUANTENNA_DRIVERS_MAKE_ENV) $(MAKE) -C $(@D) install
endef

$(eval $(call GENTARGETS))
