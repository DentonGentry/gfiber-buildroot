################################################################################
#
# libsodium
#
################################################################################

LIBSODIUM_VERSION = 1.0.8
LIBSODIUM_SITE = https://download.libsodium.org/libsodium/releases
LIBSODIUM_LICENSE = ISC
LIBSODIUM_LICENSE_FILES = LICENSE
LIBSODIUM_INSTALL_STAGING = YES
LIBSODIUM_LIBTOOL_PATCH = NO

ifeq ($(BR2_TOOLCHAIN_SUPPORTS_PIE),)
LIBSODIUM_CONF_OPTS += --disable-pie
endif

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
