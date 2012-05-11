GOOGLE_FFMPEG_SITE=repo://vendor/opensource/ffmpeg
GOOGLE_FFMPEG_DEPENDENCIES=linux
GOOGLE_FFMPEG_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_ZLIB),y)
GOOGLE_FFMPEG_CONF_OPT += --enable-zlib
GOOGLE_FFMPEG_DEPENDENCIES += zlib
else
GOOGLE_FFMPEG_CONF_OPT += --disable-zlib
endif

# We only install the program for usage by the server side
define GOOGLE_FFMPEG_INSTALL_TARGET_CMDS
        mkdir -p $(TARGET_DIR)/app/sage/
        $(INSTALL) -D -m 0755 $(@D)/ffmpeg $(TARGET_DIR)/app/sage/
endef

# Dummy AC3 decoder is not integrated so it won't be detected/played back
define GOOGLE_FFMPEG_CONFIGURE_CMDS
        (cd $(GOOGLE_FFMPEG_SRCDIR) && rm -rf config.cache && \
        $(TARGET_CONFIGURE_OPTS) \
        $(TARGET_CONFIGURE_ARGS) \
        $(GOOGLE_FFMPEG_CONF_ENV) \
        ./configure \
                --enable-cross-compile  \
                --cross-prefix=$(TARGET_CROSS) \
                --sysroot=$(STAGING_DIR) \
                --host-cc="$(HOSTCC)" \
                --arch=$(BR2_ARCH) \
                --target-os=linux \
                --extra-cflags='-fPIC -DEM8622' \
                --disable-muxers \
                --disable-encoders \
                --disable-shared \
                --enable-static \
                --disable-devices \
                --disable-demuxer=rtsp \
                --disable-protocol=rtp \
                $(GOOGLE_FFMPEG_CONF_OPT) \
        )
        echo "#define CONFIG_AC3DUMMY_DECODER 0" >>  $(GOOGLE_FFMPEG_SRCDIR)/config.h
endef

# This is not in the official installed headers but we need it for audio playback
define GOOGLE_FFMPEG_INSTALL_AUDIOCONVERT
        echo Install audioconvert header
        $(INSTALL) -D -m 0644 $(@D)/libavcodec/audioconvert.h $(STAGING_DIR)/usr/local/include/libavcodec/
endef

GOOGLE_FFMPEG_POST_INSTALL_STAGING_HOOKS+=GOOGLE_FFMPEG_INSTALL_AUDIOCONVERT

$(eval $(call AUTOTARGETS))
