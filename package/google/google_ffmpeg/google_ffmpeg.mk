GOOGLE_FFMPEG_SITE=repo://vendor/opensource/ffmpeg
GOOGLE_FFMPEG_DEPENDENCIES=
GOOGLE_FFMPEG_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_ZLIB),y)
GOOGLE_FFMPEG_CONF_OPT += --enable-zlib
GOOGLE_FFMPEG_DEPENDENCIES += zlib
else
GOOGLE_FFMPEG_CONF_OPT += --disable-zlib
endif

GOOGLE_FFMPEG_EXTRA_CFLAGS = -fPIC -DEM8622
ifeq ($(BR2_arm),y)
# The compiler version from Broadcom defaults to Thumb2, and hits a compiler
# but in this package, so we are compiling straight arm for now, it's a bit
# slow but at least compiles.
GOOGLE_FFMPEG_EXTRA_CFLAGS += -marm
endif

# We only install the program for usage by the server side
define GOOGLE_FFMPEG_INSTALL_TARGET_CMDS
        mkdir -p $(TARGET_DIR)/app/sage/
        $(INSTALL) -D -m 0755 $(@D)/ffmpeg $(TARGET_DIR)/app/sage/
endef

define GOOGLE_FFMPEG_CONFIGURE_CMDS
        (cd $(GOOGLE_FFMPEG_SRCDIR) && rm -rf config.cache && \
        $(TARGET_CONFIGURE_OPTS) \
        $(TARGET_CONFIGURE_ARGS) \
        $(GOOGLE_FFMPEG_CONF_ENV) \
        $(LOGLINEAR) ./configure \
                --enable-cross-compile  \
                --cross-prefix=$(TARGET_CROSS) \
                --sysroot=$(STAGING_DIR) \
                --host-cc="$(HOSTCC)" \
                --arch=$(BR2_ARCH) \
                --target-os=linux \
                --extra-cflags='$(GOOGLE_FFMPEG_EXTRA_CFLAGS)' \
                --disable-mmx \
                --disable-mmx2 \
                --disable-muxers \
                --disable-encoders \
                --disable-shared \
                --enable-static \
                --disable-devices \
                --disable-demuxer=rtsp \
                --disable-protocol=rtp \
                --disable-decoders \
                --enable-decoder=aac \
                --enable-decoder=ac3dummy \
                --enable-decoder=adpcm_4xm \
                --enable-decoder=adpcm_ima_amv \
                --enable-decoder=adpcm_ima_dk3 \
                --enable-decoder=adpcm_ima_dk4 \
                --enable-decoder=adpcm_ima_iss \
                --enable-decoder=adpcm_ima_qt \
                --enable-decoder=adpcm_ima_smjpeg \
                --enable-decoder=adpcm_ima_wav \
                --enable-decoder=adpcm_ima_ws \
                --enable-decoder=adpcm_ms \
                --enable-decoder=adpcm_sbpro_2 \
                --enable-decoder=adpcm_sbpro_3 \
                --enable-decoder=adpcm_sbpro_4 \
                --enable-decoder=adpcm_swf \
                --enable-decoder=adpcm_xa \
                --enable-decoder=alac \
                --enable-decoder=dcadummy \
                --enable-decoder=dts_hddummy \
                --enable-decoder=dts_madummy \
                --enable-decoder=dvbsub \
                --enable-decoder=dvdsub \
                --enable-decoder=eac3dummy \
                --enable-decoder=flac \
                --enable-decoder=flv \
                --enable-decoder=h264 \
                --enable-decoder=mjpeg \
                --enable-decoder=mlpdummy \
                --enable-decoder=mp1 \
                --enable-decoder=mp2 \
                --enable-decoder=mp3 \
                --enable-decoder=mp3adu \
                --enable-decoder=mp3on4 \
                --enable-decoder=mpeg1video \
                --enable-decoder=mpeg2video \
                --enable-decoder=mpeg4 \
                --enable-decoder=mpegvideo \
                --enable-decoder=msmpeg4 \
                --enable-decoder=msmpeg4v3 \
                --enable-decoder=pcm_alaw \
                --enable-decoder=pcm_bd \
                --enable-decoder=pcm_dvd \
                --enable-decoder=pcm_f32be \
                --enable-decoder=pcm_f32le \
                --enable-decoder=pcm_f64be \
                --enable-decoder=pcm_f64le \
                --enable-decoder=pcm_mulaw \
                --enable-decoder=pcm_s16be \
                --enable-decoder=pcm_s16le \
                --enable-decoder=pcm_s16l2_planar \
                --enable-decoder=pcm_s24be \
                --enable-decoder=pcm_s24daud \
                --enable-decoder=pcm_s24le \
                --enable-decoder=pcm_s32be \
                --enable-decoder=pcm_s32le \
                --enable-decoder=pcm_s8 \
                --enable-decoder=pcm_u16be \
                --enable-decoder=pcm_u16le \
                --enable-decoder=pcm_u24be \
                --enable-decoder=pcm_u24le \
                --enable-decoder=pcm_u32be \
                --enable-decoder=pcm_u32le \
                --enable-decoder=pcm_u8 \
                --enable-decoder=pcm_zork \
                --enable-decoder=pgssub \
                --enable-decoder=truehddummy \
                --enable-decoder=vc1 \
                --enable-decoder=vorbis \
                --enable-decoder=wavpack \
                --enable-decoder=wmv3 \
                --enable-decoder=xsub \
                $(GOOGLE_FFMPEG_CONF_OPT) \
        )
endef

# This is not in the official installed headers but we need it for audio playback
define GOOGLE_FFMPEG_INSTALL_AUDIOCONVERT
        echo Install audioconvert header
        $(INSTALL) -D -m 0644 $(@D)/libavcodec/audioconvert.h $(STAGING_DIR)/usr/local/include/libavcodec/
endef

GOOGLE_FFMPEG_POST_INSTALL_STAGING_HOOKS+=GOOGLE_FFMPEG_INSTALL_AUDIOCONVERT

$(eval $(call AUTOTARGETS))
