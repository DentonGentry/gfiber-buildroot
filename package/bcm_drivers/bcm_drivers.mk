BCM_DRIVERS_SITE=repo://vendor/broadcom/drivers
BCM_DRIVERS_INSTALL_STAGING=YES
BCM_DRIVERS_INSTALL_TARGET=YES
BCM_DRIVERS_DEPENDENCIES=linux google_platform libusb-compat

# TODO(apenwarr): Remove the old moca1 stuff after we fully move to moca2.
ifeq ($(BR2_PACKAGE_BCM_DRIVER_MOCA),y)
INSTALL_MOCA_UTILS=y
define BCM_DRIVERS_BUILD_MOCA
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CROSS=$(TARGET_CROSS) \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		LINUXDIR="$(LINUX_DIR)" \
		ARCH="$(KERNEL_ARCH)" \
		-C $(@D)/moca/
endef

define BCM_DRIVERS_INSTALL_STAGING_MOCA
	$(INSTALL) -m 0644 \
		$(@D)/moca/lib/libmoca.a \
		$(@D)/moca/util/libmocactl.a \
		$(STAGING_DIR)/usr/lib/
	$(INSTALL) -d -m 0755 \
		$(STAGING_DIR)/usr/include/moca
	rm -f $(STAGING_DIR)/usr/include/moca/linux/bmoca.h
	cp -r $(@D)/moca/include/. $(STAGING_DIR)/usr/include/moca
endef

define BCM_DRIVERS_INSTALL_TARGET_MOCA
	rm -f $(TARGET_DIR)/bin/mocap $(TARGET_DIR)/bin/mocareg
	$(INSTALL) -d -m 0755 \
		$(TARGET_DIR)/etc/moca \
		$(TARGET_DIR)/usr/lib/modules
	$(INSTALL) -m 0755 \
		$(@D)/moca/bin/mocad \
		$(@D)/moca/bin/mocactl \
		$(TARGET_DIR)/bin/
	$(INSTALL) -m 0644 \
		$(@D)/moca/mocacore-*.bin \
		$(TARGET_DIR)/etc/moca/
endef
endif  # MOCA1

ifeq ($(BR2_PACKAGE_BCM_DRIVER_MOCA2),y)
INSTALL_MOCA_UTILS=y
define BCM_DRIVERS_BUILD_MOCA
	$(TARGET_MAKE_ENV) $(MAKE1) \
		CROSS=$(TARGET_CROSS) \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		LINUXDIR="$(LINUX_DIR)" \
		ARCH="$(KERNEL_ARCH)" \
		-C $(@D)/moca2/
	cd $(@D)/google/py_moca2 && \
		PYTHONPATH=$(TARGET_PYTHONPATH) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		LDSHARED="$(TARGET_CC) -shared" \
		CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include/python2.7 \
		    -I$(@D)/moca2/lib -L$(@D)/moca2/bin " \
		$(HOST_DIR)/usr/bin/python setup.py build
	cd $(@D)/google/moca2json && \
		HOSTDIR=$(HOST_DIR) \
		DESTDIR=$(TARGET_DIR) \
		CFLAGS="$(TARGET_CFLAGS) -I$(@D)/moca2/lib -L$(@D)/moca2/bin " \
		CROSS_COMPILE=$(TARGET_CROSS) \
		$(MAKE)
endef

define BCM_DRIVERS_TEST_CMDS_MOCA
	cd $(@D)/google/moca2json && \
		HOSTDIR=$(HOST_DIR) \
		DESTDIR=$(TARGET_DIR) \
		CFLAGS="$(TARGET_CFLAGS) -I$(@D)/moca2/lib -L$(@D)/moca2/bin " \
		CROSS_COMPILE=$(TARGET_CROSS) \
		$(MAKE) test
endef

define BCM_DRIVERS_INSTALL_STAGING_MOCA
	$(INSTALL) -m 0644 \
		$(@D)/moca2/bin/libmoca.so \
		$(@D)/moca2/bin/libmocacli.so \
		$(STAGING_DIR)/usr/lib/
	$(INSTALL) -d -m 0755 \
		$(STAGING_DIR)/usr/include/moca
	rm -f $(STAGING_DIR)/usr/include/moca/linux/bmoca.h
	cp -r $(@D)/moca2/include/. $(STAGING_DIR)/usr/include/moca
endef

ifneq ($(BR2_mipsel),y)
define BCM_DRIVERS_INSTALL_MOCAREG
	# TODO(apenwarr): "mips" is a poor stand-in for "SoC w/ non-SPI MoCA"
	$(INSTALL) -m 0755 \
		$(@D)/moca2/bin/mocareg \
		$(TARGET_DIR)/bin/
endef
else
define BCM_DRIVERS_INSTALL_MOCAREG
	rm -f $(TARGET_DIR)/bin/mocareg
endef
endif

define BCM_DRIVERS_INSTALL_TARGET_MOCA
	rm -f $(TARGET_DIR)/bin/mocactl
	$(INSTALL) -d -m 0755 \
		$(TARGET_DIR)/etc/moca \
		$(TARGET_DIR)/usr/lib/modules
	$(INSTALL) -m 0755 \
		$(@D)/moca2/bin/mocad \
		$(@D)/moca2/bin/mocap \
		$(TARGET_DIR)/bin/
	$(BCM_DRIVERS_INSTALL_MOCAREG)
	$(INSTALL) -m 0644 \
		$(@D)/moca2/moca20core-*.bin \
		$(TARGET_DIR)/etc/moca/
	$(INSTALL) -m 0755 \
		$(@D)/moca2/bin/*.so \
		$(TARGET_DIR)/usr/lib/
	cd $(@D)/google/py_moca2 && \
		PYTHONPATH=$(TARGET_PYTHONPATH) \
		$(HOST_DIR)/usr/bin/python setup.py install \
			--prefix=$(TARGET_DIR)/usr
	$(INSTALL) -m 0755 \
	    $(@D)/google/moca2json/moca2json \
	    $(TARGET_DIR)/bin/
endef
endif  # MOCA2

ifeq ($(INSTALL_MOCA_UTILS),y)
define BCM_DRIVERS_INSTALL_TARGET_MOCA_COMMON
    $(INSTALL) -m 0755 package/bcm_drivers/moca_utils/* $(TARGET_DIR)/bin/
endef
endif

ifeq ($(BR2_PACKAGE_BCM_DRIVER_WIFI),y)

# NOTE(apenwarr): this could also be set to 'nodebug'.
#  But I don't know what difference that makes.
WIFI_CONFIG_PREFIX=debug

ifeq ($(BR2_PACKAGE_BCM_DRIVER_WIFI_USB),y)
BCM_MAKE_TARGETS=mipsel-mips-high
BCM_MAKE_EXTRA=BCM_EXTERNAL_MODULE=1 BRAND=external BCMEMBEDIMAGE=1
define BCM_DRIVERS_BUILD_WIFI_USB_UTILS
	$(TARGET_MAKE_ENV) $(MAKE1) \
		STBLINUX=1 \
		LINUXDIR="$(LINUX_DIR)" \
		LD="$(TARGET_LD)" \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR)" \
		STRIP="$(TARGET_STRIP)" \
		-C $(@D)/wifi/src/usbdev/usbdl \
		BUILDING_BCM_DRIVERS=1
endef
else
BCM_MAKE_TARGETS=mipsel-mips-p2p
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
	$(BCM_DRIVERS_BUILD_WIFI_USB_UTILS)
endef


ifeq ($(BR2_PACKAGE_BCM_DRIVER_WIFI_USB),y)
define BCM_DRIVERS_INSTALL_TARGET_WIFI_USB
$(INSTALL) -D -m 0444 $(@D)/wifi/src/wl/linux/obj-mipsel-mips-*/bcm_dbus.ko $(TARGET_DIR)/usr/lib/modules/bcm_dbus.ko
$(INSTALL) -D -m 0755 $(@D)/wifi/src/usbdev/usbdl/bcmdl $(TARGET_DIR)/usr/bin/bcmdl
$(INSTALL) -D -m 0444 $(@D)/wifi/src/dongle/rte/wl/builds/43236b-bmac/ag-nodis-p2p-mchan-media/rtecdc.bin.trx $(TARGET_DIR)/lib/firmware/bcm43236-firmware.bin
$(INSTALL) -D -m 0444 $(@D)/wifi/src/dongle/rte/wl/builds/43236b-bmac/ag-p2p-mchan-media/rtecdc.bin.trx $(TARGET_DIR)/lib/firmware/bcm43236-nohotplug.bin
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
	$(BCM_DRIVERS_INSTALL_TARGET_MOCA_COMMON)
endef

define BCM_DRIVERS_TEST_CMDS
    $(BCM_DRIVERS_TEST_CMDS_MOCA)
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
