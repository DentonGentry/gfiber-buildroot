GOOGLE_MCASTCAPTURE_SITE=repo://vendor/google/mcastcapture
GOOGLE_MCASTCAPTURE_DEPENDENCIES=openssl libcurl protobuf
GOOGLE_MCASTCAPTURE_INSTALL_STAGING = YES
HOST_GOOGLE_MCASTCAPTURE_DEPENDENCIES += host-gtest host-gmock host-openssl \
	host-libcurl

define GOOGLE_MCASTCAPTURE_BUILD_CMDS
	TARGET=$(TARGET_CROSS) \
	$(MAKE) -C $(@D)
endef

define HOST_GOOGLE_MCASTCAPTURE_BUILD_CMDS
	LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib:$(HOST_DIR)/lib:$(LD_LIBRARY_PATH) \
	HOSTDIR=$(HOST_DIR) \
	$(HOST_MAKE_ENV) \
	$(MAKE) -C $(@D)
endef

define GOOGLE_MCASTCAPTURE_INSTALL_STAGING_CMDS
	TARGET=$(TARGET_CROSS) \
	STAGING_DIR=$(STAGING_DIR) \
	TARGET_DIR=$(TARGET_DIR) \
	$(MAKE) -C $(@D) install_staging
endef

define GOOGLE_MCASTCAPTURE_INSTALL_TARGET_CMDS
	TARGET=$(TARGET_CROSS) \
	STAGING_DIR=$(STAGING_DIR) \
	TARGET_DIR=$(TARGET_DIR) \
	$(MAKE) -C $(@D) install_target
endef

define HOST_GOOGLE_MCASTCAPTURE_TEST_CMDS
	LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib:$(HOST_DIR)/lib:$(LD_LIBRARY_PATH) \
	HOSTDIR=$(HOST_DIR) \
	$(HOST_MAKE_ENV) \
	$(MAKE) -C $(@D) test
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
