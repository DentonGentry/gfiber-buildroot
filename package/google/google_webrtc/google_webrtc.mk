#############################################################
#
# WEBRTC (Google Talk Video / Voice software interface)
#
#############################################################
GOOGLE_WEBRTC_SITE=repo://vendor/opensource/webrtc
GOOGLE_WEBRTC_DEPENDENCIES=bruno bcm_alsa host-scons host-swtoolkit google_vc
GOOGLE_WEBRTC_INSTALL_STAGING=YES
GOOGLE_WEBRTC_INSTALL_TARGET=NO


ifeq ($(BR2_PACKAGE_BRUNO_DEBUG),y)
	BUILD_TYPE=Debug
else
	BUILD_TYPE=Release
endif

# "make merged_lib" creates the library. "make" creates all the binary test files
define GOOGLE_WEBRTC_BUILD_CMDS
	cd $(@D); \
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/local/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	python ./build/gyp_chromium --depth=. ./src/build/merge_libs.gyp -Dbuild_libjpeg=1 -Duse_libjpeg_turbo=0 -Dbuild_libyuv=1 -Ddisable_sse2=1 -Dtarget_arch=$(BR2_ARCH) -Dmips_abi=$(BR2_GCC_TARGET_ABI) -Dbruno=1 -Dbruno_cross_compile=$(TARGET_CROSS) -Dbruno_pkg_config=$(PKG_CONFIG_HOST_BINARY) -f make; \
	$(MAKE) V=1 merged_lib BUILDTYPE=$(BUILD_TYPE); \
	python ./build/gyp_chromium --depth=. webrtc.gyp -Dbuild_libjpeg=1 -Duse_libjpeg_turbo=0 -Dbuild_libyuv=1 -Ddisable_sse2=1 -Dtarget_arch=$(BR2_ARCH) -Dmips_abi=$(BR2_GCC_TARGET_ABI) -Dbruno=1 -Dbruno_cross_compile=$(TARGET_CROSS) -Dbruno_pkg_config=$(PKG_CONFIG_HOST_BINARY) -f make; \
	$(MAKE) V=1 BUILDTYPE=$(BUILD_TYPE);
endef

define GOOGLE_WEBRTC_INSTALL_STAGING_CMDS
	cp -rf $(@D)/out/$(BUILD_TYPE)/libwebrtc_linux_$(BR2_ARCH)_$(BUILD_TYPE).a $(STAGING_DIR)/usr/lib/libWebRtcMediaEngine.a
	mkdir -p $(STAGING_DIR)/usr/include/third_party/webrtc/files/include
	cp -rf \
		$(@D)/src/*.h \
		$(@D)/src/modules/interface/*.h \
		$(@D)/src/video_engine/include/*.h \
		$(@D)/src/voice_engine/main/interface/*.h \
		$(@D)/src/modules/video_render/main/interface/*.h \
		$(@D)/src/modules/video_capture/main/interface/*.h \
		$(@D)/src/modules/audio_device/main/interface/*.h \
		$(STAGING_DIR)/usr/include/third_party/webrtc/files/include/
	mkdir -p $(STAGING_DIR)/usr/include/libyuv
	cd $(@D)/third_party/libyuv/include; \
		find . -name '*.h' -exec cp '{}' '$(STAGING_DIR)/usr/include/libyuv/' \;
endef

$(eval $(call GENTARGETS))
