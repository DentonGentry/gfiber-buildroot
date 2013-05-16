#############################################################
#
# GIPS (Google Talk Voice software codec)
#
#############################################################
GOOGLE_GIPS_SITE=repo://vendor/google/gips
GOOGLE_GIPS_DEPENDENCIES=bruno host-scons host-swtoolkit google_vc
GOOGLE_GIPS_INSTALL_STAGING=YES
GOOGLE_GIPS_INSTALL_TARGET=YES

define GOOGLE_GIPS_BUILD_CMDS
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/local/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE1) -C $(@D)
endef

define GOOGLE_GIPS_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/gips/Interface
	cp -rf $(@D)/build/interface/* $(STAGING_DIR)/usr/include/gips/Interface
	$(INSTALL) -D -m 0755 $(@D)/build/libraries/VideoEngine_Linux_gcc.a $(STAGING_DIR)/usr/lib/libVoiceEngine_Linux_gcc.a
endef

define GOOGLE_GIPS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0555 $(@D)/applications/voice_engine/engine/4.0/test/LinuxTest/test $(TARGET_DIR)/home/test/gips_test
endef

$(eval $(call GENTARGETS))
