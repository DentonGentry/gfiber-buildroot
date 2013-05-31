MINDSPEED_DRIVERS_SITE=repo://vendor/mindspeed/drivers
MINDSPEED_DRIVERS_DEPENDENCIES=linux

define MINDSPEED_DRIVER_PFE_BUILD_CMDS
	$(MAKE) -C $(@D)/pfe_ctrl $(LINUX_MAKE_FLAGS) KERNELDIR=$(LINUX_DIR) PFE_DIR=../pfe
endef

define MINDSPEED_DRIVER_PFE_INSTALL_TARGET_CMDS
	$(MAKE) -C $(LINUX_DIR) $(LINUX_MAKE_FLAGS) M="$(@D)/pfe_ctrl" modules_install

        $(INSTALL) -m 0755 -D $(@D)/pfe_firmware/class_c2000.elf \
		$(TARGET_DIR)/lib/firmware/class_c2000.elf
        $(INSTALL) -m 0755 -D $(@D)/pfe_firmware/tmu_c2000.elf \
		$(TARGET_DIR)/lib/firmware/tmu_c2000.elf
        $(INSTALL) -m 0755 -D $(@D)/pfe_firmware/util_c2000.elf \
		$(TARGET_DIR)/lib/firmware/util_c2000.elf
        $(INSTALL) -m 0755 -D $(@D)/pfe_firmware/util_c2000_revA0.elf \
		$(TARGET_DIR)/lib/firmware/util_c2000_revA0.elf

        $(INSTALL) -m 0755 -D $(@D)/hotplug-script \
		$(TARGET_DIR)/sbin/hotplug
endef

define MINDSPEED_DRIVERS_BUILD_CMDS
	$(MINDSPEED_DRIVER_PFE_BUILD_CMDS)
endef

define MINDSPEED_DRIVERS_INSTALL_TARGET_CMDS
	$(MINDSPEED_DRIVER_PFE_INSTALL_TARGET_CMDS)
endef

$(eval $(call GENTARGETS))
