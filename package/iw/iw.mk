#############################################################
#
# iw
#
#############################################################

IW_VERSION = 3.14
IW_SOURCE = iw-$(IW_VERSION).tar.gz
IW_SITE = https://kernel.org/pub/software/network/iw
IW_DEPENDENCIES = host-pkg-config libnl
IW_MAKE_ENV = PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig" \
	PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config" \
	GIT_DIR="$(IW_DIR)" \
	CC="$(TARGET_CC)" \
	LD="$(TARGET_LD)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

define IW_BUILD_CMDS
	$(IW_MAKE_ENV) $(MAKE) -C $(@D) V=1
endef

define IW_INSTALL_TARGET_CMDS
	$(IW_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define IW_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/iw
	rm -f $(TARGET_DIR)/usr/share/man/man8/iw.8*
endef

$(eval $(call GENTARGETS))
