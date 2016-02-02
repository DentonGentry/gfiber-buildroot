#############################################################
#
# Helpers for using broadcom's build environment in buildroot
#
#############################################################

BCM_COMMON_SITE=repo://vendor/broadcom/common

PLAT_NOQUOTES=$(shell echo $(BR2_PACKAGE_BCM_COMMON_PLATFORM) | sed -e s/\"//g)

# BCHP_VER is used by cairo
BCHP_VER=${BR2_PACKAGE_BCM_COMMON_PLATFORM_REV}
ifeq ($(findstring $(PLAT_NOQUOTES), 97425 97428), $(PLAT_NOQUOTES))
PLAY_READY_VER=2.0
GOOG_SAGE_SUPPORT=n
else
PLAY_READY_VER=2.5
GOOG_SAGE_SUPPORT=y
endif

BCM_MAKE_ENV=\
NEXUS_TOP=${BCM_NEXUS_DIR} \
PLATFORM=${BR2_PACKAGE_BCM_COMMON_PLATFORM} \
NEXUS_PLATFORM=${BR2_PACKAGE_BCM_COMMON_PLATFORM} \
BSEAV=${BCM_BSEAV_DIR} \
LINUX=${LINUX_DIR} \
BCHP_VER=${BCHP_VER} \
PLAYBACK_IP_SUPPORT=y \
NETACCEL_SUPPORT=n \
LIVEMEDIA_SUPPORT=y \
MEDIA_AVI_SUPPORT=y \
MEDIA_ASF_SUPPORT=y \
BHDM_CEC_SUPPORT=n \
BCEC_SUPPORT=y \
LIVE_STREAMING_SUPPORT=y \
HLS_PROTOCOL_SUPPORT=n \
V3D_SUPPORT=y \
KERNELMODE=n \
AUTO_PSI_SUPPORT=y \
SSL_SUPPORT=y \
NEXUS_MODE= \
DTCP_IP_SUPPORT=n \
DTCP_IP_HARDWARE_ENCRYPTION=n \
DTCP_IP_HARDWARE_DECRYPTION=n \
B_HAS_PLAYPUMP_IP=n \
MULTI_BUILD=n \
NEXUS_HDCP_SUPPORT=y \
MSDRM_PRDY_SUPPORT=y \
MSDRM_PD_HWDECRYPT=y \
PRDY_ROBUSTNESS_ENABLE=y \
PRDY_NEXUS_IO=y \
MSDRM_PRDY_SDK_VERSION=$(PLAY_READY_VER) \
APPLIBS_PLAYREADY=y \
KEYLADDER_SUPPORT=y \
OTPMSP_SUPPORT=y \
USERCMD_SUPPORT=y \
BHSM_SECURE_RSA=OFF \
BHSM_OTPMSP=ON \
BHSM_KEYLADDER=ON \
HSM_SOURCE_AVAILABLE=y \
BSP_M2M_EXT_KEY_IV_SUPPORT=ON \
PLAYBACKDEVICE_STAND_ALONE_APPLICATION=n \
TOOLCHAIN_ROOT=$(HOST_DIR)/usr/bin/ \
SC_PLATFORM=bcm${BR2_PACKAGE_BCM_COMMON_PLATFORM}nexus \
BVDC_MACROVISION=y \
BRUNO_DEFINES="BRUNO_PLATFORM=1 BRUNO_PLATFORM_GFHD100=1" \
BSP_SC_VALUE_SUPPORT=ON \
BSID_MJPEG_SUPPORT=y \
B_REFSW_OPENSSL_IS_EXTERNAL=y \
MINICLIENT_PATH=${GOOGLE_MINICLIENT_DIR} \
GLFW_NEXUS_PATH=${GOOGLE_GLFW_NEXUS_DIR} \
NEXUS_COMMON_CRYPTO_SUPPORT=y \
SAGE_SUPPORT=${GOOG_SAGE_SUPPORT} \
SAGE_SECURE_MODE=6

ifeq ($(findstring $(PLAT_NOQUOTES), 97425 97428), $(PLAT_NOQUOTES))
BCM_MAKE_ENV += SAGE_ON=y
BCM_MAKE_ENV += WVCDM_VERSION=2.1
BCM_MAKE_ENV += APPLIBS_WIDEVINE=y
endif

BCM_MAKE_ENV += B_REFSW_DEBUG=y
# NOTE(apenwarr): this could also be set to 'release'.
#  That disables debug logs and makes things slightly smaller/faster. 
#  However, since we capture the logs for analysis, we will probably always
#  want debug mode.
BCM_COMMON_BUILD_TYPE=debug

BCM_MAKEFLAGS=
BCM_MAKEFLAGS += CROSS_COMPILE="${TARGET_CROSS}"
BCM_MAKEFLAGS += TOOLCHAIN_DIR="${HOST_DIR}/usr/bin"
ifeq ($(BR2_mipsel),y)
BCM_MAKEFLAGS += B_REFSW_ARCH=mipsel-linux
else
BCM_MAKEFLAGS += B_REFSW_ARCH=arm-linux
endif
BCM_MAKEFLAGS += PATH=${HOST_DIR}/usr/bin:${PATH}
BCM_MAKEFLAGS += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig"
BCM_MAKEFLAGS += HOST_DIR="${HOST_DIR}"
BCM_MAKEFLAGS += APPLIBS_TOP=${BCM_APPS_DIR}

NETFLIX_MAKEFLAGS=
NETFLIX_MAKEFLAGS += TOOLCHAIN_DIR="${HOST_DIR}/usr/bin"
ifeq ($(BR2_mipsel),y)
NETFLIX_MAKEFLAGS += B_REFSW_ARCH=mipsel-linux
else
NETFLIX_MAKEFLAGS += B_REFSW_ARCH=arm-linux
endif
NETFLIX_MAKEFLAGS += B_REFSW_TOOLCHAIN_DIR="${HOST_DIR}/usr"
NETFLIX_MAKEFLAGS += CROSS_COMPILE="${TARGET_CROSS}"
NETFLIX_MAKEFLAGS += PATH=${HOST_DIR}/usr/bin:${PATH}
NETFLIX_MAKEFLAGS += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig"

#export NETACCEL_SUPPORT=y
#export LIVEMEDIA_SUPPORT=n
#export MEDIA_ASF_SUPPORT=y
#export B_HAS_PLAYPUMP_IP=y
#export DTCP_IP_SUPPORT=y
#export DTCP_IP_HARDWARE_ENCRYPTION=y
#export DTCP_IP_HARDWARE_DECRYPTION=y

define BCM_COMMON_USE_BUILD_SYSTEM
       $(RM) -rf $1/common
       ln -sf $(BCM_COMMON_DIR)/common $1/common
       mkdir -p $(@D)/opensource
       $(RM) -rf $1/opensource/common
       ln -sf $(BCM_COMMON_DIR)/opensource/common $1/opensource/common
endef

ifeq ($(BR2_mipsel),y)
define BCM_COMMON_BUILD_EXTRACT_TARBALL
       rm -f $(@D)/target/${BR2_PACKAGE_BCM_COMMON_PLATFORM}*.mipsel-linux*$(BCM_COMMON_BUILD_TYPE).*tgz
       $(BCM_MAKE_ENV) $(MAKE1) $(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) -C $(@D)/common bundle
       $(TAR) -xf $(@D)/target/${BR2_PACKAGE_BCM_COMMON_PLATFORM}*.mipsel-linux*$(BCM_COMMON_BUILD_TYPE).*tgz -C $(1)
endef
else
define BCM_COMMON_BUILD_EXTRACT_TARBALL
       rm -f $(@D)/target/${BR2_PACKAGE_BCM_COMMON_PLATFORM}*.arm-linux*$(BCM_COMMON_BUILD_TYPE).*tgz
       $(BCM_MAKE_ENV) $(MAKE1) $(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) -C $(@D)/common bundle
       $(TAR) -xf $(@D)/target/${BR2_PACKAGE_BCM_COMMON_PLATFORM}*.arm-linux*$(BCM_COMMON_BUILD_TYPE).*tgz -C $(1)
endef
endif

$(eval $(call GENTARGETS))
