#############################################################
#
# libjingle (Google Talk Voice and P2P Interoperability Library)
#
#############################################################
GOOGLE_LIBJINGLE_SITE=repo://vendor/opensource/libjingle
GOOGLE_LIBJINGLE_DEPENDENCIES=bruno bcm_alsa host-scons host-swtoolkit google_gips google_webrtc

PATH_TO_SWTOOLKIT=$(HOST_DIR)/usr/lib/swtoolkit

define GOOGLE_LIBJINGLE_BUILD_CMDS
	(cd $(@D); \
	PATH=${HOST_DIR}/usr/bin:${PATH} talk/third_party/expat-2.0.1/configure \
            --build=$(GNU_HOST_NAME) \
            --host=$(GNU_TARGET_NAME) \
            --target=$(GNU_TARGET_NAME); \
	PATH=${HOST_DIR}/usr/bin:${PATH} talk/third_party/srtp/configure \
            --build=$(GNU_HOST_NAME) \
            --host=$(GNU_TARGET_NAME) \
            --target=$(GNU_TARGET_NAME); \
	PATH=${HOST_DIR}/usr/bin:${PATH} talk/third_party/gtest/configure \
            --build=$(GNU_HOST_NAME) \
            --host=$(GNU_TARGET_NAME) \
            --target=$(GNU_TARGET_NAME); \
	cd $(@D)/talk; \
	SCONS_DIR=$(HOST_DIR)/usr/lib/scons-2.0.1 CROSS_COMPILE=${TARGET_CROSS} $(PATH_TO_SWTOOLKIT)/hammer.sh --host-platform=LINUX --verbose)
endef

define GOOGLE_LIBJINGLE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/talk/build/dbg/obj/login $(TARGET_DIR)/home/test/login
	$(INSTALL) -D -m 0755 $(@D)/talk/build/dbg/obj/call $(TARGET_DIR)/home/test/call
endef

$(eval $(call GENTARGETS))
