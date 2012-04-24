BCM_NEXUS_SITE=repo://vendor/broadcom/nexus
# TODO (by kedong) The dependency on bruno will be moved to board level
# config in buildroot.
BCM_NEXUS_DEPENDENCIES=linux bruno bcm_magnum bcm_bseav host-pkg-config
BCM_NEXUS_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/nexus
BCM_NEXUS_INSTALL_STAGING=YES
BCM_NEXUS_INSTALL_TARGET=YES

BCM_NEXUS_STAGING_PATH=usr/lib/nexus


define BCM_NEXUS_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/../BSEAV/lib/drmrootfs all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/build all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/examples pkg-config
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/utils all
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/examples apps
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D)/lib/os
	cd $(@D)/../BSEAV/lib/playbackdevice && $(BCM_MAKE_ENV) NEXUS=$(BCM_NEXUS_DIR) NEXUS_MGR_DIR=$(@D)/../BSEAV/lib/playbackdevice/nexusMgr/ $(MAKE) $(BCM_MAKEFLAGS) all
endef

define BCM_NEXUS_INSTALL_STAGING_CMDS
	ln -sf $(@D) $(STAGING_DIR)/$(BCM_NEXUS_STAGING_PATH)
	sed -i"" -e "s@$(@D)@/$(BCM_NEXUS_STAGING_PATH)@g" -e "s@std=c89@std=c99@g" $(@D)/bin/nexus.pc
	$(INSTALL) -D $(@D)/bin/nexus.pc $(STAGING_DIR)/usr/lib/pkgconfig/nexus.pc
	$(INSTALL) -D $(@D)/../BSEAV/lib/playbackdevice/bin/libnexusMgr.so $(STAGING_DIR)/usr/lib/libnexusMgr.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/playbackdevice/bin/libPlaybackDevice.so $(STAGING_DIR)/usr/lib/libPlaybackDevice.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/security/common_drm/lib/7425/CARD/libcmndrm.so $(STAGING_DIR)/usr/lib/libcmndrm.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/common_crypto/lib/7425/libcmncrypto.so $(STAGING_DIR)/usr/lib/libcmncrypto.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/drmrootfs/libdrmrootfs.so $(STAGING_DIR)/usr/lib/libdrmrootfs.so
	$(INSTALL) -D $(@D)/bin/libb_os.so $(STAGING_DIR)/usr/local/lib/libb_os.so
endef

define BCM_NEXUS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 644 -D $(@D)/bin/bcmdriver.ko $(TARGET_DIR)/usr/lib/modules/bcmdriver.ko
	$(INSTALL) -D $(@D)/bin/libnexus.so $(TARGET_DIR)/usr/lib/libnexus.so
	$(INSTALL) -D $(BCM_NEXUS_SECURITY_LIB).so $(TARGET_DIR)/usr/lib/libnexus_security.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/playbackdevice/bin/libnexusMgr.so $(TARGET_DIR)/usr/lib/libnexusMgr.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/playbackdevice/bin/libPlaybackDevice.so $(TARGET_DIR)/usr/lib/libPlaybackDevice.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/security/common_drm/lib/7425/CARD/libcmndrm.so $(TARGET_DIR)/usr/lib/libcmndrm.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/common_crypto/lib/7425/libcmncrypto.so $(TARGET_DIR)/usr/lib/libcmncrypto.so
	$(INSTALL) -D $(@D)/../BSEAV/lib/drmrootfs/libdrmrootfs.so $(TARGET_DIR)/usr/lib/libdrmrootfs.so
endef

$(eval $(call GENTARGETS,package,bcm_nexus))
