MINDSPEED_DRIVERS_SITE=$(call qstrip,$(BR2_PACKAGE_MINDSPEED_DRIVERS_GIT_REPO_URL))

MINDSPEED_DRIVERS_DEPENDENCIES=linux libcli libnetfilter_conntrack libpcap

ifeq ($(BR2_PACKAGE_GOOGLE_SPACECAST),y)
MINDSPEED_DRIVERS_CONF_ENV=CFLAGS="$(TARGET_CFLAGS) -DCOMCERTO_2000 \
 -Wno-error -DIPSEC_SUPPORT_DISABLED"
else
MINDSPEED_DRIVERS_CONF_ENV=CFLAGS="$(TARGET_CFLAGS) -DCOMCERTO_2000 \
 -Wno-error -DWIFI_ENABLE -DIPSEC_SUPPORT_DISABLED -DAUTO_BRIDGE"
endif

MINDSPEED_DRIVERS_MAKE_ENV = \
	LINUX_DIR="$(LINUX_DIR)" \
	INSTALL="$(INSTALL)" \
	LINUX_MAKE_FLAGS='$(LINUX_MAKE_FLAGS)'

MINDSPEED_DRIVERS_PRE_CONFIGURE_HOOKS += MINDSPEED_DRIVERS_AUTORECONF_HOOK

# mindspeed_drivers is not a real autotools package as per buildroot's
# definition. Instead, it contains two separate autotools projects in the
# subdirectories cmm/ and fci/lib/. So instead of running
# $(HOST_DIR)/usr/bin/autoreconf, we run autoreconf_subdirs which is a shell script
# that recursively runs autoreconf in these two subdirectories.

define MINDSPEED_DRIVERS_AUTORECONF_HOOK
	$(subst $(HOST_DIR)/usr/bin/autoreconf,./autoreconf_subdirs $(HOST_DIR)/usr/bin/autoreconf,$(AUTORECONF_HOOK))
endef

define MINDSPEED_DRIVERS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) $($(PKG)_MAKE) $($(PKG)_MAKE_OPT) STAGING_DIR="$(STAGING_DIR)" TARGET_DIR="$(TARGET_DIR)" -C $($(PKG)_SRCDIR)
	for i in $$(find $(STAGING_DIR)/usr/lib* -name "*.la"); do \
		cp -f $$i $$i~; \
		$(SED) "s:\(['= ]\)/usr:\\1$(STAGING_DIR)/usr:g" $$i; \
	done
endef

define MINDSPEED_DRIVERS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D package/mindspeed_drivers/S45cmm $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 0644 -D package/mindspeed_drivers/fastforward.config \
		$(TARGET_DIR)/etc
endef

$(eval $(call AUTOTARGETS))
