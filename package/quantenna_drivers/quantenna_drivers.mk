QUANTENNA_DRIVERS_SITE=repo://vendor/quantenna/drivers
QUANTENNA_DRIVERS_DEPENDENCIES=linux

ifeq ($(BR2_PACKAGE_QUANTENNA_DRIVERS_PCIE_HOST),y)

define QUANTENNA_DRIVERS_BUILD_CMDS
	$(MAKE) -C $(@D)/libqcsapi_client CC="$(TARGET_CC)"
endef

define QUANTENNA_DRIVERS_INSTALL_TARGET_CMDS
	cp -a $(@D)/libqcsapi_client/qcsapi_pcie_static $(TARGET_DIR)/usr/bin
endef

else ifeq ($(BR2_PACKAGE_QUANTENNA_DRIVERS_PCIE_MODULE),y)

define QUANTENNA_DRIVERS_BUILD_CMDS
	$(MAKE) MAKEFLAGS="-j1" -C $(@D)/qcsapi-1.0.1 EXTRA_PROGS="call_qcsapi_rpcd qcsapi_rpcd" CC="$(TARGET_CC)" STRIP="$(TARGET_STRIP)" XCFLAGS="$(TARGET_CFLAGS)" PREFIX="$(TARGET_DIR)" build_all
endef

define QUANTENNA_DRIVERS_INSTALL_TARGET_CMDS
	cp -a $(@D)/fs/common/* $(TARGET_DIR)
	cp -a $(@D)/fs/pcie_module/* $(TARGET_DIR)
	$(MAKE) MAKEFLAGS="-j1" -C $(@D)/qcsapi-1.0.1 EXTRA_PROGS="call_qcsapi_rpcd qcsapi_rpcd" CC="$(TARGET_CC)" STRIP="$(TARGET_STRIP)" XCFLAGS="$(TARGET_CFLAGS)" PREFIX="$(TARGET_DIR)" install
endef

else ifeq ($(BR2_PACKAGE_QUANTENNA_DRIVERS_STANDALONE),y)

define QUANTENNA_DRIVERS_BUILD_CMDS
	$(MAKE) MAKEFLAGS="-j1" -C $(@D)/qcsapi-1.0.1 CC="$(TARGET_CC)" STRIP="$(TARGET_STRIP)" XCFLAGS="$(TARGET_CFLAGS)" PREFIX="$(TARGET_DIR)" build_all
endef

define QUANTENNA_DRIVERS_INSTALL_TARGET_CMDS
	cp -a $(@D)/fs/common/* $(TARGET_DIR)
	cp -a $(@D)/fs/standalone/* $(TARGET_DIR)
	$(MAKE) MAKEFLAGS="-j1" -C $(@D)/qcsapi-1.0.1 CC="$(TARGET_CC)" STRIP="$(TARGET_STRIP)" XCFLAGS="$(TARGET_CFLAGS)" PREFIX="$(TARGET_DIR)" install
endef

endif

$(eval $(call GENTARGETS))
