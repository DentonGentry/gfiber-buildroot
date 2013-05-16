#############################################################
#
# Helpers for using broadcom's build environment in buildroot
#
#############################################################

BCM_COMMON_SITE=repo://vendor/broadcom/common

# BCHP_VER is used by cairo
BCHP_VER=B2

BCM_MAKE_ENV=\
NEXUS_TOP=${BCM_NEXUS_DIR} \
PLATFORM=97425 \
BSEAV=${BCM_BSEAV_DIR} \
LINUX=${LINUX_DIR} \
BCHP_VER=${BCHP_VER} \
POWERSTANDBY_SUPPORT=n \
NEXUS_POWER_MANAGEMENT=n \
NEXUS_POWER_STANDBY=n \
PLAYBACK_IP_SUPPORT=y \
NETACCEL_SUPPORT=n \
LIVEMEDIA_SUPPORT=y \
MEDIA_AVI_SUPPORT=y \
MEDIA_ASF_SUPPORT=y \
BHDM_CEC_SUPPORT=n \
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
NEXUS_TEMP_MONITOR_SUPPORT=y \
NEXUS_HDCP_SUPPORT=y \
MSDRM_PRDY_SUPPORT=y \
MSDRM_PD_HWDECRYPT=y \
PRDY_ROBUSTNESS_ENABLE=y \
NEXUS_SECURITY_KEYLADDER_EXTENSION_INC=${BCM_NEXUS_DIR}/extensions/security/keyladder/keyladder_ext.inc \
NEXUS_SECURITY_OTPMSP_EXTENSION_INC=${BCM_NEXUS_DIR}/extensions/security/otpmsp/otpmsp_ext.inc \
NEXUS_SECURITY_USERCMD_EXTENSION_INC=${BCM_NEXUS_DIR}/extensions/security/usercmd/usercmd_ext.inc \
BHSM_SECURE_RSA=OFF \
BHSM_OTPMSP=ON \
BHSM_KEYLADDER=ON \
HSM_SOURCE_AVAILABLE=y \
BSP_M2M_EXT_KEY_IV_SUPPORT=ON \
PLAYBACKDEVICE_STAND_ALONE_APPLICATION=y \
TOOLCHAIN_ROOT=$(HOST_DIR)/usr/bin/ \
SC_PLATFORM=bcm97425nexus \
BVDC_MACROVISION=y \
BRUNO_DEFINES="BRUNO_PLATFORM=1 BRUNO_PLATFORM_GFHD100=1" \
BSP_SC_VALUE_SUPPORT=ON \
BSID_MJPEG_SUPPORT=y \
NEXUS_COMMON_CRYPTO_SUPPORT=y

BCM_MAKE_ENV += B_REFSW_DEBUG=y
# NOTE(apenwarr): this could also be set to 'release'.
#  That disables debug logs and makes things slightly smaller/faster. 
#  However, since we capture the logs for analysis, we will probably always
#  want debug mode.
BCM_COMMON_BUILD_TYPE=debug

BCM_MAKEFLAGS=
BCM_MAKEFLAGS += CROSS_COMPILE="${TARGET_CROSS}"
BCM_MAKEFLAGS += TOOLCHAIN_DIR="${HOST_DIR}/usr/bin"
BCM_MAKEFLAGS += B_REFSW_ARCH=mipsel-linux
BCM_MAKEFLAGS += PATH=${HOST_DIR}/usr/bin:${PATH}
BCM_MAKEFLAGS += PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig"
BCM_MAKEFLAGS += HOST_DIR="${HOST_DIR}"
BCM_MAKEFLAGS += APPLIBS_TOP=${BCM_APPS_DIR}

NETFLIX_MAKEFLAGS=
NETFLIX_MAKEFLAGS += TOOLCHAIN_DIR="${HOST_DIR}/usr/bin"
NETFLIX_MAKEFLAGS += B_REFSW_ARCH=mipsel-linux
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

define BCM_COMMON_BUILD_EXTRACT_TARBALL
       rm -f $(@D)/target/97425*.mipsel-linux*$(BCM_COMMON_BUILD_TYPE).*tgz
       $(BCM_MAKE_ENV) $(MAKE1) $(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) -C $(@D)/common bundle
       $(TAR) -xf $(@D)/target/97425*.mipsel-linux*$(BCM_COMMON_BUILD_TYPE).*tgz -C $(1)
endef

$(eval $(call GENTARGETS))
