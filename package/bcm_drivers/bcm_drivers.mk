BCM_DRIVERS_SITE=repo://vendor/broadcom/drivers
BCM_DRIVERS_INSTALL_TARGET=YES

ifeq ($(BR2_PACKAGE_BCM_DRIVER_MOCA),y)
define BCM_DRIVERS_BUILD_MOCA
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CROSS=$(TARGET_CROSS) \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		-C $(@D)/moca/
endef

define BCM_DRIVERS_INSTALL_TARGET_MOCA
	$(INSTALL) -m 0700 $(@D)/moca/bin/mocad $(TARGET_DIR)/bin/
	$(INSTALL) -m 0700 $(@D)/moca/bin/mocactl $(TARGET_DIR)/bin/
	$(INSTALL) -m 0700 $(@D)/moca/bin/soapserver $(TARGET_DIR)/bin/
	$(INSTALL) -D -m 0600 $(@D)/moca/mocacore-gen1.bin $(TARGET_DIR)/etc/moca/mocacore-gen1.bin
	$(INSTALL) -D -m 0600 $(@D)/moca/mocacore-gen2.bin $(TARGET_DIR)/etc/moca/mocacore-gen2.bin
	$(INSTALL) -D -m 0600 $(@D)/moca/mocacore-gen3.bin $(TARGET_DIR)/etc/moca/mocacore-gen3.bin
endef
endif

ifeq ($(BR2_PACKAGE_BCM_DRIVER_WIFI),y)

ifeq ($(BR2_PACKAGE_BRUNO_DEBUG),y)
WIFI_CONFIG_PREFIX=debug
else
WIFI_CONFIG_PREFIX=nodebug
endif

define BCM_DRIVERS_BUILD_WIFI
	$(TARGET_MAKE_ENV) $(MAKE1) \
		STBLINUX=1 \
		LINUXDIR="$(LINUX_DIR)" \
		-C $(@D)/wifi/wl/linux \
		$(WIFI_CONFIG_PREFIX)-mipsel-mips
	$(TARGET_MAKE_ENV) $(MAKE1) \
		TARGETENV="linuxmips" \
		LINUXDIR="$(LINUX_DIR)" \
		-f GNUmakefile \
		-C $(@D)/wifi/wl/exe
endef

define BCM_DRIVERS_INSTALL_TARGET_WIFI
	$(INSTALL) -D -m 0600 $(@D)/wifi/wl/linux/obj-$(WIFI_CONFIG_PREFIX)-mipsel-mips-*/wl.ko $(TARGET_DIR)/usr/lib/modules/wl.ko
	$(INSTALL) -m 0700 $(@D)/wifi/wl/exe/wlmips $(TARGET_DIR)/usr/bin/wl
endef

endif

ifeq ($(BR2_PACKAGE_BCM_DRIVER_BLUETOOTH),y)
BCM_DRIVERS_DEPENDENCIES+=alsa-lib alsa-utils linux
define BCM_DRIVERS_CLEAN_BLUETOOTH
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CPU=mips \
		MIPSGCC=$(TARGET_CC_NOCCACHE) \
		MIPSGCCLIBPATH="" \
		ENABLE_BTHID=TRUE \
		ENABLE_ALSA=TRUE \
		-f Makefile.all clean \
		-C $(@D)/bt/3rdparty/embedded/bsa_examples/linux/server/build/
endef

define BCM_DRIVERS_BUILD_BLUETOOTH
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CPU=mips \
		MIPSGCC=$(TARGET_CC_NOCCACHE) \
		MIPSGCCLIBPATH="" \
		ENABLE_BTHID=TRUE \
		ENABLE_ALSA=TRUE \
		-f Makefile.all clean all \
		-C $(@D)/bt/3rdparty/embedded/bsa_examples/linux/server/build/
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		KDIR="${LINUX_DIR}" \
		-C $(@D)/bt/3rdparty/embedded/brcm/linux/bthid/
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		KDIR="${LINUX_DIR}" \
		-C $(@D)/bt/3rdparty/embedded/brcm/linux/btusb/
endef

define BCM_DRIVERS_INSTALL_TARGET_BLUETOOTH
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/server/build/mips/bsa_server $(TARGET_DIR)/usr/bin/
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
	$(INSTALL) -m 0700 $(@D)/bt/3rdparty/embedded/bsa_examples/linux/app_ag/build/mips/app_ag $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0600 $(@D)/bt/3rdparty/embedded/brcm/linux/btusb/btusb.ko $(TARGET_DIR)/usr/lib/modules/btusb.ko
	$(INSTALL) -D -m 0600 $(@D)/bt/3rdparty/embedded/brcm/linux/bthid/bthid.ko $(TARGET_DIR)/usr/lib/modules/bthid.ko
endef
endif

define BCM_DRIVERS_BUILD_CMDS
	$(BCM_DRIVERS_BUILD_BLUETOOTH)
	$(BCM_DRIVERS_BUILD_MOCA)
	$(BCM_DRIVERS_BUILD_WIFI)
endef

define BCM_DRIVERS_CLEAN_CMDS
	$(BCM_DRIVERS_CLEAN_BLUETOOTH)
endef

define BCM_DRIVERS_INSTALL_TARGET_CMDS
	$(BCM_DRIVERS_INSTALL_TARGET_BLUETOOTH)
	$(BCM_DRIVERS_INSTALL_TARGET_MOCA)
	$(BCM_DRIVERS_INSTALL_TARGET_WIFI)
endef

$(eval $(call GENTARGETS,package,bcm_drivers))
