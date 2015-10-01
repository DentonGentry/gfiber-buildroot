HFW_GLAUKUS_HAL_SITE=repo://vendor/hfw/glaukus-hal
HFW_GLAUKUS_HAL_INSTALL_STAGING=YES
HFW_GLAUKUS_HAL_INSTALL_TARGET=YES

HOST_HFW_GLAUKUS_HAL_DEPENDENCIES=
HFW_GLAUKUS_HAL_DEPENDENCIES=

HFW_GLAUKUS_HAL_HOST_CFLAGS=
HFW_GLAUKUS_HAL_TARGET_CFLAGS=

HOST_HFW_GLAUKUS_HAL_ENV=
HFW_GLAUKUS_HAL_ENV=

HOST_HFW_GLAUKUS_HAL_MFLAGS= \
	CFLAGS=-I$(HOST_DIR)/usr/include \
	XLDFLAGS=-L$(HOST_DIR)/usr/lib \

HFW_GLAUKUS_HAL_MFLAGS= \
	PCC="$(HOST_DIR)/usr/bin/protoc" \
	CC="$(TARGET_CC)" \
	CXX="$(TARGET_CXX)" \
	LD="$(TARGET_CC)" \
	TARGET_CFLAGS=-I$(STAGING_DIR)/usr/include \
	XTARGET_LDFLAGS=-L$(STAGING_DIR)/usr/lib \
	INSTALL_DIR=$(STAGING_DIR)/usr/include \
	LIB_PREFIX=$(STAGING_DIR)/usr/lib \

HOST_HFW_GLAUKUS_HAL_MAKE=$(HOST_HFW_GLAUKUS_HAL_ENV) $(MAKE) $(HOST_HFW_GLAUKUS_HAL_MFLAGS)
HFW_GLAUKUS_HAL_MAKE=$(HFW_GLAUKUS_HAL_ENV) $(MAKE) $(HFW_GLAUKUS_HAL_MFLAGS)

define HOST_HFW_GLAUKUS_HAL_BUILD_CMDS
	$(HOST_HFW_GLAUKUS_HAL_MAKE) -C $(@D)
endef

define HFW_GLAUKUS_HAL_BUILD_CMDS
	$(HFW_GLAUKUS_HAL_MAKE) -C $(@D)
endef

define HOST_HFW_GLAUKUS_HAL_TEST_CMDS
	$(HOST_HFW_GLAUKUS_HAL_MAKE) -C $(@D) test
endef

define HOST_HFW_GLAUKUS_HAL_INSTALL_CMDS
	$(HOST_HFW_GLAUKUS_HAL_MAKE) -C $(@D) install
endef

define HFW_GLAUKUS_HAL_INSTALL_STAGING_CMDS
	$(HFW_GLAUKUS_HAL_MAKE) -C $(@D) install
endef

define HFW_GLAUKUS_HAL_INSTALL_TARGET_CMDS
	true $(HFW_GLAUKUS_HAL_MAKE) -C $(@D) install
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
