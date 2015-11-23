BCM_NEXUS_SITE=repo://vendor/broadcom/nexus
BCM_NEXUS_DEPENDENCIES=linux bcm_magnum bcm_bseav host-pkg-config
BCM_NEXUS_INSTALL_STAGING=YES
BCM_NEXUS_INSTALL_TARGET=YES

BCM_NEXUS_STAGING_PATH=usr/lib/nexus

ifdef BR2_mipsel
BCM_ARCH=mips
else
BCM_ARCH=arm
endif

PLAT_NOQUOTES=$(shell echo $(BR2_PACKAGE_BCM_COMMON_PLATFORM) | sed -e s/\"//g)
ifeq ($(findstring $(PLAT_NOQUOTES), 97425 97428), $(PLAT_NOQUOTES))
BCM_CMNDRM_DIR=Zeus20
endif
ifeq ($(findstring $(PLAT_NOQUOTES), 97250 97252 97439), $(PLAT_NOQUOTES))
BCM_CMNDRM_DIR=Zeus4x
#BCM_MAKEFLAGS += NEXUS_SECURITY_SUPPORT=n
endif

ifeq ($(BCM_CMNDRM_DIR),,)
$(error The chip $(BR2_PACKAGE_BCM_COMMON_PLATFORM) is not supported here.)
endif

define BCM_NEXUS_CONFIGURE_CMDS
	ln -sf $(@D) $(BUILD_DIR)/nexus
	mkdir -p $(@D)/obj.$(BR2_PACKAGE_BCM_COMMON_PLATFORM)
	ln -sf $(@D)/obj.$(BR2_PACKAGE_BCM_COMMON_PLATFORM) \
		$(@D)/../obj.$(BR2_PACKAGE_BCM_COMMON_PLATFORM)
	mkdir -p $(@D)/obj.mipsel-linux
	ln -sf $(@D)/obj.mipsel-linux $(@D)/../obj.mipsel-linux
	ln -sf $(@D)/../obj.$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/nexus/bin \
		$(BUILD_DIR)/nexus/bin
endef

define BCM_NEXUS_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/../BSEAV/lib/security/bcrypt all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/../BSEAV/lib/drmrootfs install
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/../BSEAV/lib/livemedia all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/build all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/build nexus_headers
	$(BCM_MAKE_ENV) NEXUS_MODE=client $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/build all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/nxclient/build
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/examples B_REFSW_REAL_MAKE=1 pkg-config
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/utils all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/examples B_REFSW_REAL_MAKE=1 apps install
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/lib/os
	cd $(@D)/../BSEAV/lib/playbackdevice && $(BCM_MAKE_ENV) NEXUS=$(BCM_NEXUS_DIR) NEXUS_MGR_DIR=$(@D)/../BSEAV/lib/playbackdevice/nexusMgr/ $(MAKE) $(BCM_MAKEFLAGS) all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/../BSEAV/lib/media/build
endef

define BCM_NEXUS_INSTALL_LIBS
	$(INSTALL) -D $(@D)/../BSEAV/lib/drmrootfs/lib/$(BCM_ARCH)/linuxuser/libdrmrootfs.so $1/usr/lib/libdrmrootfs.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/playbackdevice/bin/libPlaybackDevice.so $1/usr/lib/libPlaybackDevice.so
	$(INSTALL) -D $(@D)/obj.$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/BSEAV/lib/security/bcrypt/libbcrypt.so $1/usr/lib/libbcrypt.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/security/common_drm/lib/$(BCM_CMNDRM_DIR)/debug/libcmndrm.so $1/usr/lib/libcmndrm.so
	$(if $(filter $(BCM_ARCH),mips),$(INSTALL) -D $(@D)/../BSEAV/lib/security/third_party/widevine/CENC21/oemcrypto/lib/$(BCM_ARCH)/liboemcrypto.so $1/usr/lib/liboemcrypto.so,)
	$(INSTALL) -D $(@D)/bin/libb_os.so $1/usr/lib/libb_os.so
	$(INSTALL) -D $(@D)/bin/libnexus.so $1/usr/lib/libnexus.so
	$(INSTALL) -D $(@D)/bin/libnexus_client.so $1/usr/lib/libnexus_client.so
	$(INSTALL) -D $(@D)/bin/libnxclient.so $1/usr/lib/libnxclient.so
	if [ -f $(@D)/bin/sage_os_app.bin ]; then \
	  mkdir -p $1/usr/lib/sage_firmware; \
	  $(INSTALL) -D $(@D)/bin/sage_os_app.bin $1/usr/lib/sage_firmware; \
	  $(INSTALL) -D $(@D)/bin/sage_bl.bin $1/usr/lib/sage_firmware; \
	fi
endef

define BCM_NEXUS_INSTALL_STAGING_CMDS
	ln -sf $(@D) $(STAGING_DIR)/$(BCM_NEXUS_STAGING_PATH)
	sed -i"" -e "s@$(@D)@/$(BCM_NEXUS_STAGING_PATH)@g" -e "s@std=c89@std=c99@g" $(@D)/bin/nexus.pc
	$(INSTALL) -D $(@D)/bin/nexus.pc $(STAGING_DIR)/usr/lib/pkgconfig/nexus.pc
	$(call BCM_NEXUS_INSTALL_LIBS,$(STAGING_DIR))
endef

define BCM_NEXUS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/shared
	$(INSTALL) -m 644 -D $(@D)/bin/bcmdriver.ko $(TARGET_DIR)/usr/lib/modules/bcmdriver.ko
	$(INSTALL) -m 700 -D $(@D)/../obj.$(BR2_PACKAGE_BCM_COMMON_PLATFORM)/nexus/utils/playback \
		$(TARGET_DIR)/usr/local/bin/playback
	$(call BCM_NEXUS_INSTALL_LIBS,$(TARGET_DIR))
endef

$(eval $(call GENTARGETS))
