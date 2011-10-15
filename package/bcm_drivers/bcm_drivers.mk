BCM_DRIVERS_SITE=repo://vendor/broadcom/drivers
BCM_DRIVERS_INSTALL_TARGET=YES

ifeq ($(BR2_PACKAGE_BCM_DRIVER_MOCA),y)
define BCM_DRIVERS_BUILD_MOCA
	$(TARGET_MAKE_ENV) $(MAKE) \
		CROSS=$(TARGET_CROSS) \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
	-C $(@D)/moca/
endef

define BCM_DRIVERS_INSTALL_TARGET_MOCA
	mkdir -p $(TARGET_DIR)/bin $(TARGET_DIR)/lib/modules $(TARGET_DIR)/etc/moca
	mkdir -p $(TARGET_DIR)/etc/moca && \
	$(INSTALL) -m 0700 $(@D)/moca/lib/mocad $(TARGET_DIR)/bin/ && \
	$(INSTALL) -m 0700 $(@D)/moca/util/mocactl $(TARGET_DIR)/bin/ && \
	$(INSTALL) -m 0700 $(@D)/moca/soapserver/soapserver $(TARGET_DIR)/bin/ && \
	$(INSTALL) -m 0700 $(@D)/moca/mocacore-gen1.bin $(TARGET_DIR)/etc/moca/ && \
	$(INSTALL) -m 0700 $(@D)/moca/mocacore-gen2.bin $(TARGET_DIR)/etc/moca/
endef
endif


# :TODO: (by kedong when bluetooth and wifi code is available)
ifeq ($(BR2_PACKAGE_BCM_DRIVER_WIFI),y)
define BCM_DRIVERS_BUILD_WIFI
endef

define BCM_DRIVERS_INSTALL_TARGET_WIFI
endef
endif

ifeq ($(BR2_PACKAGE_BCM_DRIVER_BLUETOOTH),y)
define BCM_DRIVERS_BUILD_BLUETOOTH
endef

define BCM_DRIVERS_INSTALL_TARGET_BLUETOOTH
endef
endif

define BCM_DRIVERS_BUILD_CMDS
	$(BCM_DRIVERS_BUILD_BLUETOOTH)
	$(BCM_DRIVERS_BUILD_MOCA)
	$(BCM_DRIVERS_BUILD_WIFI)
endef

define BCM_DRIVERS_INSTALL_TARGET_CMDS
	$(BCM_DRIVERS_INSTALL_TARGET_BLUETOOTH)
	$(BCM_DRIVERS_INSTALL_TARGET_MOCA)
	$(BCM_DRIVERS_INSTALL_TARGET_WIFI)
endef

$(eval $(call GENTARGETS,package,bcm_drivers))
