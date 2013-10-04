#############################################################
#
# libcli
#
#############################################################
# Mindspeed's SDK 2.8.5 uses version 1.9.4 of libcli. Let's use the same.
LIBCLI_VERSION=1.9.4
LIBCLI_SOURCE=libcli-$(LIBCLI_VERSION).tar.gz
LIBCLI_SITE=https://github.com/dparrish/libcli/tarball/release-$(LIBCLI_VERSION)
LIBCLI_INSTALL_STAGING=YES

LIBCLI_MAKE_OPT=CC="$(TARGET_CC)" DEBUG="" OPTIM="" PREFIX=/usr
LIBCLI_INSTALL_STAGING_OPT=$(LIBCLI_MAKE_OPT) DESTDIR="$(STAGING_DIR)" install
LIBCLI_INSTALL_TARGET_OPT=$(LIBCLI_MAKE_OPT) DESTDIR="$(TARGET_DIR)" install

define LIBCLI_BUILD_CMDS
  $(TARGET_CONFIGURE_OPTS) $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(LIBCLI_MAKE_OPT) libcli.so
endef

define LIBCLI_INSTALL_STAGING_CMDS
  rm -rf $(STAGING_DIR)/usr/lib/libcli.so*
  $(TARGET_CONFIGURE_OPTS) $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(LIBCLI_INSTALL_STAGING_OPT)
endef

define LIBCLI_INSTALL_TARGET_CMDS
  rm -rf $(TARGET_DIR)/usr/lib/libcli.so*
  $(TARGET_CONFIGURE_OPTS) $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(LIBCLI_INSTALL_TARGET_OPT)
endef

$(eval $(call GENTARGETS))
