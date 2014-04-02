BCM_BLUETOOTH_SITE=repo://vendor/broadcom/drivers
BCM_BLUETOOTH_INSTALL_TARGET=YES
BCM_BLUETOOTH_DEPENDENCIES = alsa-lib alsa-utils bcm_nexus

ifeq ($(BR2_PACKAGE_BCM_BLUETOOTH_BSA),y)
define BCM_BLUETOOTH_BSA_CLEAN
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CPU=mips \
		MIPSGCC=$(TARGET_CC_NOCCACHE) \
		MIPSGCCLIBPATH="" \
		ENABLE_BTHID=TRUE \
		-f Makefile.all clean \
		-C $(@D)/bt/3rdparty/embedded/google/bruno/server/build/
endef

define BCM_BLUETOOTH_BSA_BUILD
	$(BCM_MAKE_ENV) $(TARGET_MAKE_ENV) $(MAKE1) \
		CPU=mips \
		MIPSGCC=$(TARGET_CC_NOCCACHE) \
		MIPSGCCLIBPATH="" \
		ENABLE_BTHID=TRUE \
		-f Makefile.all all \
		-C $(@D)/bt/3rdparty/embedded/google/bruno/server/build/
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		KDIR="${LINUX_DIR}" \
		-C $(@D)/bt/3rdparty/embedded/brcm/linux/bthid/
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		KDIR="${LINUX_DIR}" \
		-C $(@D)/bt/3rdparty/embedded/brcm/linux/btusb/
endef

define BCM_BLUETOOTH_BSA_INSTALL_TARGET
	$(INSTALL) -m 0755 $(@D)/bt/3rdparty/embedded/google/bruno/server/build/mips/bsa_server $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0755 $(@D)/bt/3rdparty/embedded/google/bruno/app_gtv/build/mips/app_gtv $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0600 $(@D)/bt/3rdparty/embedded/brcm/linux/btusb/btusb.ko $(TARGET_DIR)/usr/lib/modules/btusb.ko
	$(INSTALL) -D -m 0600 $(@D)/bt/3rdparty/embedded/brcm/linux/bthid/bthid.ko $(TARGET_DIR)/usr/lib/modules/bthid.ko
	$(INSTALL) -m 0755 $(@D)/bt/3rdparty/embedded/google/bruno/libbsa/build/mips/sharedlib/libbsa.so $(TARGET_DIR)/usr/lib/
endef
else
define BCM_BLUETOOTH_BSA_CLEAN
endef
define BCM_BLUETOOTH_BSA_BUILD
endef
define BCM_BLUETOOTH_BSA_INSTALL_TARGET
endef
endif

ifeq ($(BR2_PACKAGE_BCM_BLUETOOTH_FW),y)
define BCM_BLUETOOTH_FW_INSTALL_TARGET
	$(INSTALL) -D -m 0400 $(@D)/fw/BCM20702.hcd $(TARGET_DIR)/lib/firmware/brcm/BCM20702.hcd
	$(INSTALL) -D -m 0400 $(@D)/fw/BCM20705.hcd $(TARGET_DIR)/lib/firmware/brcm/BCM20705.hcd
endef
else
define BCM_BLUETOOTH_FW_INSTALL_TARGET
endef
endif

define BCM_BLUETOOTH_CLEAN_CMDS
	$(BCM_BLUETOOTH_BSA_CLEAN)
endef

define BCM_BLUETOOTH_BUILD_CMDS
	$(BCM_BLUETOOTH_BSA_BUILD)
endef

define BCM_BLUETOOTH_INSTALL_TARGET_CMDS
	$(BCM_BLUETOOTH_BSA_INSTALL_TARGET)
	$(BCM_BLUETOOTH_FW_INSTALL_TARGET)
endef

$(eval $(call GENTARGETS))
