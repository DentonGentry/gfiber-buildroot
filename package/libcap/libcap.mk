#############################################################
#
# libcap
#
#############################################################

LIBCAP_VERSION = 2.22
# Until kernel.org is completely back up use debian mirror
#LIBCAP_SITE = http://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2
LIBCAP_SITE = $(BR2_DEBIAN_MIRROR)/debian/pool/main/libc/libcap2
LIBCAP_SOURCE = libcap2_$(LIBCAP_VERSION).orig.tar.gz
HOST_LIBCAP_DEPENDENCIES =
LIBCAP_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_LIBCAP_SETCAP),y)
LIBCAP_DEPENDENCIES = host-libcap attr
LIBCAP_FLAGS = "RAISE_SETFCAP=no LIBATTR=yes"
BINARIES_TO_RM = capsh getpcaps getcap
else
LIBCAP_DEPENDENCIES = host-libcap
LIBCAP_FLAGS = "LIBATTR=no"
BINARIES_TO_RM = capsh getpcaps
endif

define LIBCAP_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) \
		$(LIBCAP_FLAGS) BUILD_CC="$(HOSTCC)" BUILD_CFLAGS="$(HOST_CFLAGS)"
endef

define LIBCAP_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(LIBCAP_FLAGS) DESTDIR=$(STAGING_DIR) \
		prefix=/usr lib=lib install
endef

define LIBCAP_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(LIBCAP_FLAGS) DESTDIR=$(TARGET_DIR) \
		prefix=/usr lib=lib install
	rm -f $(addprefix $(TARGET_DIR)/usr/sbin/,$(BINARIES_TO_RM))
endef

define HOST_LIBCAP_BUILD_CMDS
	$(HOST_MAKE_ENV) $(HOST_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(LIBCAP_FLAGS)
endef

define HOST_LIBCAP_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) $(LIBCAP_FLAGS) DESTDIR=$(HOST_DIR) \
		prefix=/usr lib=lib install
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
