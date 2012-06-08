BCM_BLUETOOTH_SITE=repo://vendor/broadcom/drivers
BCM_BLUETOOTH_INSTALL_STAGING=YES
BCM_BLUETOOTH_INSTALL_TARGET=YES

BCM_BLUETOOTH_DEPENDENCIES = alsa-lib alsa-utils linux bcm_nexus
define BCM_BLUETOOTH_CLEAN_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CPU=mips \
		MIPSGCC=$(TARGET_CC_NOCCACHE) \
		MIPSGCCLIBPATH="" \
		ENABLE_BTHID=TRUE \
		-f Makefile.all clean \
		-C $(@D)/bt/3rdparty/embedded/bsa_examples/linux/server/build/
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CPU=mips \
		MIPSGCC=$(TARGET_CC_NOCCACHE) \
		MIPSGCCLIBPATH="" \
		ENABLE_BTHID=TRUE \
		-f Makefile.all clean \
		-C $(@D)/bt/3rdparty/embedded/google/bruno/server/build/
endef

define BCM_BLUETOOTH_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CPU=mips \
		MIPSGCC=$(TARGET_CC_NOCCACHE) \
		MIPSGCCLIBPATH="" \
		ENABLE_BTHID=TRUE \
		-f Makefile.all all \
		-C $(@D)/bt/3rdparty/embedded/bsa_examples/linux/server/build/
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

define BCM_BLUETOOTH_INSTALL_STAGING_CMDS
	$(INSTALL) -m 0600 $(@D)/bt/3rdparty/embedded/google/bruno/app_gtv/build/mips/libapp_gtv.a $(STAGING_DIR)/usr/lib/
	$(INSTALL) -m 0600 $(@D)/bt/3rdparty/embedded/google/bruno/libbsa/build/mips/libbsa.a $(STAGING_DIR)/usr/lib/
	mkdir -p $(STAGING_DIR)/usr/include/bt && \
	cp -pr $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_*/include/*.h $(STAGING_DIR)/usr/include/bt
	cp -pr $(@D)/bt/3rdparty/embedded/bsa_examples/linux/simple_app/include/*.h $(STAGING_DIR)/usr/include/bt
	cp -pr $(@D)/bt/3rdparty/embedded/bsa_examples/linux/libbsa/include/*.h $(STAGING_DIR)/usr/include/bt
	cp -pr $(@D)/bt/3rdparty/embedded/google/bruno/app_gtv/include/*.h $(STAGING_DIR)/usr/include/bt
endef

define BCM_BLUETOOTH_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/google/bruno/server/build/mips/bsa_server $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_tm/build/mips/app_tm $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_pbs/build/mips/app_pbs $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_ops/build/mips/app_ops $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_opc/build/mips/app_opc $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_manager/build/mips/app_manager $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_hs/build/mips/app_hs $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_hl/build/mips/app_hl $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_hh/build/mips/app_hh $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_fts/build/mips/app_fts $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_ftc/build/mips/app_ftc $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_dg/build/mips/app_dg $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_avk/build/mips/app_avk $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_av/build/mips/app_av $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/google/bruno/app_gtv/build/mips/app_gtv $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0600 $(@D)/bt/3rdparty/embedded/brcm/linux/btusb/btusb.ko $(TARGET_DIR)/usr/lib/modules/btusb.ko
	$(INSTALL) -D -m 0600 $(@D)/bt/3rdparty/embedded/brcm/linux/bthid/bthid.ko $(TARGET_DIR)/usr/lib/modules/bthid.ko
endef

$(eval $(call GENTARGETS))
