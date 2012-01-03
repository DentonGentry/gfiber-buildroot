#############################################################
#
# vc (Google fiber VC)
#
#############################################################
GOOGLE_VC_SITE=repo://vendor/google/telepresence
GOOGLE_VC_INSTALL_STAGING=YES

GOOGLE_VC_DEPENDENCIES=bcm_nexus
GOOGLE_VC_INSTALL_STAGING=YES

GOOGLE_VC_STAGING_PATH=usr/lib/vc

ifeq ($(BR2_PACKAGE_BRUNO_DEBUG),y)
define GOOGLE_VC_BUILD_TEST_CMDS
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/local/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	TARGET_CROSS=$(TARGET_CROSS) $(MAKE) -C $(@D) test
endef
define GOOGLE_VC_INSTALL_TEST_STAGING_CMDS
	$(INSTALL) -D -m 0444 $(@D)/bin/libvcme.a $(STAGING_DIR)/usr/lib/libvcme.a
	$(INSTALL) -D -m 0444 $(@D)/bin/libvcme.so $(STAGING_DIR)/usr/lib/libvcme.so
endef
define GOOGLE_VC_INSTALL_TEST_TARGET_CMDS
	$(INSTALL) -D -m 0555 $(@D)/bin/tp_ts $(TARGET_DIR)/home/test/tp_ts
	$(INSTALL) -D -m 0555 $(@D)/bin/tp_es $(TARGET_DIR)/home/test/tp_es
	$(INSTALL) -D -m 0555 $(@D)/bin/tp_mjpg $(TARGET_DIR)/home/test/tp_mjpg
	$(INSTALL) -D -m 0555 $(@D)/bin/tp_ext_h264 $(TARGET_DIR)/home/test/tp_ext_h264
	$(INSTALL) -D -m 0555 $(@D)/bin/tp_namuga $(TARGET_DIR)/home/test/tp_namuga
	$(INSTALL) -D -m 0555 $(@D)/bin/tp_demo $(TARGET_DIR)/home/test/tp_demo
	$(INSTALL) -D -m 0555 $(@D)/bin/test_ir $(TARGET_DIR)/home/test/test_ir
	$(INSTALL) -D -m 0555 $(@D)/bin/test_send $(TARGET_DIR)/home/test/test_send
	$(INSTALL) -D -m 0555 $(@D)/bin/test_pcm $(TARGET_DIR)/home/test/test_pcm
	$(INSTALL) -D -m 0555 $(@D)/bin/test_alsa $(TARGET_DIR)/home/test/test_alsa
	$(INSTALL) -D -m 0555 $(@D)/bin/test_audio $(TARGET_DIR)/home/test/test_audio
	$(INSTALL) -D -m 0444 $(@D)/bin/libvcme.so $(TARGET_DIR)/usr/lib/libvcme.so
endef
else
define GOOGLE_VC_BUILD_TEST_CMDS
endef
define GOOGLE_VC_INSTALL_TEST_STAGING_CMDS
endef
define GOOGLE_VC_INSTALL_TEST_TARGET_CMDS
endef
endif

define GOOGLE_VC_BUILD_CMDS
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/local/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	TARGET_CROSS=$(TARGET_CROSS) $(MAKE) -C $(@D) all
	$(GOOGLE_VC_BUILD_TEST_CMDS)
endef

define GOOGLE_VC_INSTALL_STAGING_CMDS
	$(GOOGLE_VC_INSTALL_TEST_STAGING_CMDS)
	$(INSTALL) -D -m 0444 $(@D)/mediaengine/audiomixer.h $(STAGING_DIR)/usr/include/audiomixer.h
	$(INSTALL) -D -m 0444 $(@D)/mediaengine/audioplayout.h $(STAGING_DIR)/usr/include/audioplayout.h
	$(INSTALL) -D -m 0444 $(@D)/bin/libvcme_audio.so $(STAGING_DIR)/usr/lib/libvcme_audio.so
	sed -i"" -e "s@$(@D)@/$(GOOGLE_VC_STAGING_PATH)@g" $(@D)/bin/vcme.pc
	$(INSTALL) -D -m 0444 $(@D)/bin/vcme.pc $(STAGING_DIR)/usr/lib/pkgconfig/vcme.pc
endef

define GOOGLE_VC_INSTALL_TARGET_CMDS
	$(GOOGLE_VC_INSTALL_TEST_TARGET_CMDS)
	$(INSTALL) -D -m 0444 $(@D)/bin/libvcme_audio.so $(TARGET_DIR)/usr/lib/libvcme_audio.so
endef

$(eval $(call GENTARGETS,package/google,google_vc))
