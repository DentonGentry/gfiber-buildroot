#############################################################
#
# libjingle (Google Talk Voice and P2P Interoperability Library)
#
#############################################################
LIBJINGLE_SITE=repo://vendor/opensource/libjingle
LIBJINGLE_INSTALL_STAGING=YES

LIBJINGLE_DEPENDENCIES=linux bruno bcm_alsa host-scons host-swtoolkit
LIBJINGLE_INSTALL_STAGING=YES

LIBJINGLE_STAGING_PATH=usr/lib/libjingle
PATH_TO_SWTOOLKIT=$(HOST_DIR)/usr/lib/swtoolkit

define LIBJINGLE_BUILD_CMDS
	(cd $(@D); \
	talk/third_party/expat-2.0.1/configure; \
	talk/third_party/srtp/configure; \
	cd $(@D)/talk; \
	SCONS_DIR=$(HOST_DIR)/usr/lib/scons-2.0.1 $(PATH_TO_SWTOOLKIT)/hammer.sh)
endef

define LIBJINGLE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/app/telepresence && \
	cp -rf $(@D)/talk/build/dbg/obj/ $(TARGET_DIR)/app/telepresence
endef

$(eval $(call GENTARGETS,package/google,libjingle))
