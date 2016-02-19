QUANTENNA_DRIVERS_SITE=repo://vendor/quantenna/drivers
QUANTENNA_DRIVERS_DEPENDENCIES=linux

ifeq ($(BR2_PACKAGE_QUANTENNA_DRIVERS_PCIE_HOST),y)

define QUANTENNA_DRIVERS_BUILD_CMDS
	$(MAKE) -C $(@D)/quantenna-kmsgd CC="$(TARGET_CC)" quantenna-kmsgd
	$(MAKE) -C $(@D)/libqcsapi_client CC="$(TARGET_CC)"
endef

define QUANTENNA_DRIVERS_INSTALL_TARGET_CMDS
	cp -a $(@D)/topaz-linux.lzma.img $(TARGET_DIR)/lib/firmware
	cp -a $(@D)/quantenna-kmsgd/quantenna-kmsgd $(TARGET_DIR)/usr/bin
	cp -a $(@D)/libqcsapi_client/qcsapi_pcie_static $(TARGET_DIR)/usr/bin
endef

else ifeq ($(BR2_PACKAGE_QUANTENNA_DRIVERS_PCIE_MODULE),y)

define QUANTENNA_DRIVERS_BUILD_CMDS
	$(MAKE) -C $(@D)/kmsgcat CC="$(TARGET_CC)" kmsgcat
	$(MAKE) MAKEFLAGS="-j1" -C $(@D)/qcsapi-1.0.1 EXTRA_PROGS="call_qcsapi_rpcd qcsapi_rpcd" CC="$(TARGET_CC)" STRIP="$(TARGET_STRIP)" XCFLAGS="$(TARGET_CFLAGS)" PREFIX="$(TARGET_DIR)" build_all
endef

define QUANTENNA_DRIVERS_INSTALL_TARGET_CMDS
	cp -a $(@D)/fs/common/* $(TARGET_DIR)
	cp -a $(@D)/fs/pcie_module/* $(TARGET_DIR)
	cp -a $(@D)/kmsgcat/kmsgcat $(TARGET_DIR)/usr/bin
	$(MAKE) MAKEFLAGS="-j1" -C $(@D)/qcsapi-1.0.1 EXTRA_PROGS="call_qcsapi_rpcd qcsapi_rpcd" CC="$(TARGET_CC)" STRIP="$(TARGET_STRIP)" XCFLAGS="$(TARGET_CFLAGS)" PREFIX="$(TARGET_DIR)" install
endef

else ifeq ($(BR2_PACKAGE_QUANTENNA_DRIVERS_STANDALONE),y)

define QUANTENNA_DRIVERS_BUILD_CMDS
	$(MAKE) -C $(@D)/kmsgcat CC="$(TARGET_CC)" kmsgcat
	$(MAKE) MAKEFLAGS="-j1" -C $(@D)/qcsapi-1.0.1 CC="$(TARGET_CC)" STRIP="$(TARGET_STRIP)" XCFLAGS="$(TARGET_CFLAGS)" PREFIX="$(TARGET_DIR)" build_all
endef

define QUANTENNA_DRIVERS_INSTALL_TARGET_CMDS
	cp -a $(@D)/fs/common/* $(TARGET_DIR)
	cp -a $(@D)/fs/standalone/* $(TARGET_DIR)
	cp -a $(@D)/kmsgcat/kmsgcat $(TARGET_DIR)/usr/bin
	$(MAKE) MAKEFLAGS="-j1" -C $(@D)/qcsapi-1.0.1 CC="$(TARGET_CC)" STRIP="$(TARGET_STRIP)" XCFLAGS="$(TARGET_CFLAGS)" PREFIX="$(TARGET_DIR)" install
endef

endif

$(eval $(call GENTARGETS))
