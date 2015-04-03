MINDSPEED_DRIVERS_SITE=repo://vendor/mindspeed/drivers
MINDSPEED_DRIVERS_DEPENDENCIES=linux libcli libnetfilter_conntrack libpcap

ifeq ($(BR2_PACKAGE_GOOGLE_SPACECAST),y)
MINDSPEED_DRIVERS_CONF_ENV=CFLAGS="$(TARGET_CFLAGS) -DCOMCERTO_2000 \
 -Wno-error -DIPSEC_SUPPORT_DISABLED"

MINDSPEED_DRIVERS_MAKE_ENV = \
	LINUX_DIR="$(LINUX_DIR)" \
	INSTALL="$(INSTALL)" \
	LINUX_MAKE_FLAGS='$(LINUX_MAKE_FLAGS)'
else
MINDSPEED_DRIVERS_CONF_ENV=CFLAGS="$(TARGET_CFLAGS) -DCOMCERTO_2000 \
 -Wno-error -DWIFI_ENABLE -DIPSEC_SUPPORT_DISABLED -DAUTO_BRIDGE"

MINDSPEED_DRIVERS_MAKE_ENV = \
	LINUX_DIR="$(LINUX_DIR)" \
	INSTALL="$(INSTALL)" \
	LINUX_MAKE_FLAGS='$(LINUX_MAKE_FLAGS)'
endif

define MINDSPEED_DRIVERS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) $($(PKG)_MAKE) $($(PKG)_MAKE_OPT) STAGING_DIR="$(STAGING_DIR)" TARGET_DIR="$(TARGET_DIR)" -C $($(PKG)_SRCDIR)
	for i in $$(find $(STAGING_DIR)/usr/lib* -name "*.la"); do \
		cp -f $$i $$i~; \
		$(SED) "s:\(['= ]\)/usr:\\1$(STAGING_DIR)/usr:g" $$i; \
	done
endef
define MINDSPEED_DRIVERS_INSTALL_TARGET_CMDS
	@echo "Already installed this package as part of build process"
endef
define MINDSPEED_DRIVERS_INSTALL_TARGET_CMDS
	@echo "Already installed this package as part of build process"
endef

$(eval $(call AUTOTARGETS))
