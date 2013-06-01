BCM_BLUETOOTH_SITE=repo://vendor/broadcom/drivers
BCM_BLUETOOTH_INSTALL_TARGET=YES
BCM_BLUETOOTH_DEPENDENCIES = alsa-lib alsa-utils bcm_nexus

define BCM_BLUETOOTH_CLEAN_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CPU=mips \
		MIPSGCC=$(TARGET_CC_NOCCACHE) \
		MIPSGCCLIBPATH="" \
		ENABLE_BTHID=TRUE \
		-f Makefile.all clean \
		-C $(@D)/bt/3rdparty/embedded/google/bruno/server/build/
endef

define BCM_BLUETOOTH_BUILD_CMDS
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

define BCM_BLUETOOTH_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/google/bruno/server/build/mips/bsa_server $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/google/bruno/app_gtv/build/mips/app_gtv $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0600 $(@D)/bt/3rdparty/embedded/brcm/linux/btusb/btusb.ko $(TARGET_DIR)/usr/lib/modules/btusb.ko
	$(INSTALL) -D -m 0600 $(@D)/bt/3rdparty/embedded/brcm/linux/bthid/bthid.ko $(TARGET_DIR)/usr/lib/modules/bthid.ko
	$(INSTALL) -m 0600 $(@D)/bt/3rdparty/embedded/google/bruno/libbsa/build/mips/sharedlib/libbsa.so $(TARGET_DIR)/usr/lib/
endef

$(eval $(call GENTARGETS))
