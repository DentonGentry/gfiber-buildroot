BCM_NEXUS_SITE=repo://vendor/broadcom/nexus
BCM_NEXUS_DEPENDENCIES=linux bcm_magnum bcm_bseav host-pkg-config
BCM_NEXUS_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/nexus
BCM_NEXUS_INSTALL_STAGING=YES
BCM_NEXUS_INSTALL_TARGET=YES

BCM_NEXUS_STAGING_PATH=usr/lib/nexus


define BCM_NEXUS_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/../BSEAV/lib/drmrootfs all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/build all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/examples pkg-config
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/utils all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/examples apps install
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/lib/os
	cd $(@D)/../BSEAV/lib/playbackdevice && $(BCM_MAKE_ENV) NEXUS=$(BCM_NEXUS_DIR) NEXUS_MGR_DIR=$(@D)/../BSEAV/lib/playbackdevice/nexusMgr/ $(MAKE) $(BCM_MAKEFLAGS) all
endef

define BCM_NEXUS_INSTALL_STAGING_CMDS
	ln -sf $(@D) $(STAGING_DIR)/$(BCM_NEXUS_STAGING_PATH)
	sed -i"" -e "s@$(@D)@/$(BCM_NEXUS_STAGING_PATH)@g" -e "s@std=c89@std=c99@g" $(@D)/bin/nexus.pc
	$(INSTALL) -D $(@D)/bin/nexus.pc $(STAGING_DIR)/usr/lib/pkgconfig/nexus.pc
	$(INSTALL) -D $(@D)/../BSEAV/lib/playbackdevice/bin/libnexusMgr.so $(STAGING_DIR)/usr/lib/libnexusMgr.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/playbackdevice/bin/libPlaybackDevice.so $(STAGING_DIR)/usr/lib/libPlaybackDevice.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/security/common_drm/lib/7425/libcmndrm.so $(STAGING_DIR)/usr/lib/libcmndrm.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/drmrootfs/lib/linuxuser/libdrmrootfs.so $(STAGING_DIR)/usr/lib/libdrmrootfs.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/security/bcrypt/lib/libbcrypt.so $(STAGING_DIR)/usr/lib/libbcrypt.so
	$(INSTALL) -D $(@D)/bin/libb_os.so $(STAGING_DIR)/usr/local/lib/libb_os.so
endef

define BCM_NEXUS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 644 -D $(@D)/bin/bcmdriver.ko $(TARGET_DIR)/usr/lib/modules/bcmdriver.ko
	$(INSTALL) -D $(@D)/bin/libnexus.so $(TARGET_DIR)/usr/lib/libnexus.so
	$(INSTALL) -m 755 -D $(@D)/bin/binverify $(TARGET_DIR)/home/test/binverify
	$(INSTALL) -m 755 -D $(@D)/bin/otpmsptest $(TARGET_DIR)/home/test/otpmsptest
	$(INSTALL) -m 644 -D $(@D)/examples/UserCmdTest/rsa_init_SHA1_1024k2u31_1024k1u31_1024k0u31_1024k3u0.dat $(TARGET_DIR)/home/test/rsa_init_SHA1_1024k2u31_1024k1u31_1024k0u31_1024k3u0.dat
	$(INSTALL) -D $(@D)/../BSEAV/lib/playbackdevice/bin/libnexusMgr.so $(TARGET_DIR)/usr/lib/libnexusMgr.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/playbackdevice/bin/libPlaybackDevice.so $(TARGET_DIR)/usr/lib/libPlaybackDevice.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/security/common_drm/lib/7425/libcmndrm.so $(TARGET_DIR)/usr/lib/libcmndrm.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/security/bcrypt/lib/libbcrypt.so $(TARGET_DIR)/usr/lib/libbcrypt.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/drmrootfs/lib/linuxuser/libdrmrootfs.so $(TARGET_DIR)/usr/lib/libdrmrootfs.so
endef

$(eval $(call GENTARGETS))
