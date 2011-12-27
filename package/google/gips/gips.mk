#############################################################
#
# GIPS (Google Talk Voice software codec)
#
#############################################################
GOOGLE_GIPS_SITE=repo://vendor/google/gips
GOOGLE_GIPS_DEPENDENCIES=linux bruno bcm_alsa host-scons host-swtoolkit google_vc
GOOGLE_GIPS_INSTALL_STAGING=YES
GOOGLE_GIPS_INSTALL_TARGET=NO

define GOOGLE_GIPS_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE1) -C $(@D) -f make_all.txt
endef

define GOOGLE_GIPS_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/gips/Interface
	cp -rf $(@D)/build/interface/* $(STAGING_DIR)/usr/include/gips/Interface
	$(INSTALL) -D -m 0755 $(@D)/build/libraries/VoiceEngine_Linux_gcc.a $(STAGING_DIR)/usr/lib/libVoiceEngine_Linux_gcc.a
endef

$(eval $(call GENTARGETS,package/google,google_gips))
