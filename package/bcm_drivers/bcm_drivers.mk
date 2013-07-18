BCM_DRIVERS_SITE=repo://vendor/broadcom/drivers
BCM_DRIVERS_INSTALL_STAGING=YES
BCM_DRIVERS_INSTALL_TARGET=YES
BCM_DRIVERS_DEPENDENCIES=linux google_platform

ifeq ($(BR2_PACKAGE_BCM_DRIVER_MOCA),y)
define BCM_DRIVERS_BUILD_MOCA
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CROSS=$(TARGET_CROSS) \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		-C $(@D)/moca/
endef

define BCM_DRIVERS_INSTALL_STAGING_MOCA
	$(INSTALL) -D -m 0644 $(@D)/moca/lib/libmoca.a $(STAGING_DIR)/usr/lib/libmoca.a
	$(INSTALL) -D -m 0644 $(@D)/moca/util/libmocactl.a $(STAGING_DIR)/usr/lib/libmocactl.a
	mkdir -p $(STAGING_DIR)/usr/include/moca && \
	cp -pr $(@D)/moca/include/* $(STAGING_DIR)/usr/include/moca
endef

define BCM_DRIVERS_INSTALL_TARGET_MOCA
	$(INSTALL) -m 0700 $(@D)/moca/bin/mocad $(TARGET_DIR)/bin/
	$(INSTALL) -m 0700 $(@D)/moca/bin/mocactl $(TARGET_DIR)/bin/
	$(INSTALL) -m 0700 $(@D)/moca/bin/soapserver $(TARGET_DIR)/bin/
	$(INSTALL) -D -m 0600 $(@D)/moca/mocacore-gen3.bin $(TARGET_DIR)/etc/moca/mocacore-gen3.bin
endef
endif

ifeq ($(BR2_PACKAGE_BCM_DRIVER_WIFI),y)

# NOTE(apenwarr): this could also be set to 'nodebug'.
#  But I don't know what difference that makes.
WIFI_CONFIG_PREFIX=debug

ifeq ($(BR2_PACKAGE_BCM_DRIVER_WIFI_USB),y)
BCM_MAKE_TARGETS=mipsel-mips-high
BCM_MAKE_EXTRA=BCM_EXTERNAL_MODULE=1 BRAND=external BCMEMBEDIMAGE=1
else
BCM_MAKE_TARGETS=mipsel-mips
BCM_MAKE_EXTRA=
endif

define BCM_DRIVERS_BUILD_WIFI
	$(TARGET_MAKE_ENV) $(MAKE1) \
		STBLINUX=1 \
		LINUXDIR="$(LINUX_DIR)" \
		LD="$(TARGET_LD)" \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR)" \
		STRIP="$(TARGET_STRIP)" \
		-C $(@D)/wifi/src/wl/linux \
		$(BCM_MAKE_TARGETS) $(BCM_MAKE_EXTRA) \
		BUILDING_BCM_DRIVERS=1
	$(TARGET_MAKE_ENV) $(MAKE1) \
		TARGETENV="linuxmips" \
		LINUXDIR="$(LINUX_DIR)" \
		LD="$(TARGET_LD)" \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR)" \
		STRIP="$(TARGET_STRIP)" \
		-f GNUmakefile \
		-C $(@D)/wifi/src/wl/exe \
		BUILDING_BCM_DRIVERS=1
endef


ifeq ($(BR2_PACKAGE_BCM_DRIVER_WIFI_USB),y)
define BCM_DRIVERS_INSTALL_TARGET_WIFI_USB
$(INSTALL) -D -m 0600 $(@D)/wifi/src/wl/linux/obj-mipsel-mips-*/bcm_dbus.ko $(TARGET_DIR)/usr/lib/modules/bcm_dbus.ko
endef
else
define BCM_DRIVERS_INSTALL_TARGET_WIFI_USB
endef
endif

define BCM_DRIVERS_INSTALL_TARGET_WIFI
	$(INSTALL) -D -m 0600 $(@D)/wifi/src/wl/linux/obj-mipsel-mips-*/wl.ko $(TARGET_DIR)/usr/lib/modules/wl.ko
	$(INSTALL) -m 0700 $(@D)/wifi/src/wl/exe/wlmips $(TARGET_DIR)/usr/bin/wl
	$(BCM_DRIVERS_INSTALL_TARGET_WIFI_USB)
endef

endif

define BCM_DRIVERS_BUILD_CMDS
	$(BCM_DRIVERS_BUILD_MOCA)
	$(BCM_DRIVERS_BUILD_WIFI)
endef

define BCM_DRIVERS_CLEAN_CMDS
endef

define BCM_DRIVERS_INSTALL_STAGING_CMDS
	$(BCM_DRIVERS_INSTALL_STAGING_MOCA)
endef

define BCM_DRIVERS_INSTALL_TARGET_CMDS
	$(BCM_DRIVERS_INSTALL_TARGET_MOCA)
	$(BCM_DRIVERS_INSTALL_TARGET_WIFI)
endef

$(eval $(call GENTARGETS))
