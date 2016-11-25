GOOGLE_MCASTCAPTURE_SITE=repo://vendor/google/mcastcapture
GOOGLE_MCASTCAPTURE_DEPENDENCIES=openssl libcurl protobuf zlib google_platform \
	google_libgep libevent libxml2 google_gflags
GOOGLE_MCASTCAPTURE_INSTALL_STAGING = YES
HOST_GOOGLE_MCASTCAPTURE_DEPENDENCIES += host-googletest host-openssl \
	host-libcurl host-protobuf host-zlib host-google_platform \
	host-libevent host-google_libgep host-libxml2 host-google_gflags

define GOOGLE_MCASTCAPTURE_BUILD_CMDS
	TARGET=$(TARGET_CROSS) \
	HOSTDIR=$(HOST_DIR) \
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

define GOOGLE_MCASTCAPTURE_COVERAGE_CMDS
	TARGET=$(TARGET_CROSS) \
	HOSTDIR=$(HOST_DIR) \
	$(MAKE) -C $(@D) cross-coverage
endef

define HOST_GOOGLE_MCASTCAPTURE_TEST_CMDS
	TARGET=unittest; \
	if [ "$(TSAN)" ]; then TARGET=ThreadSanitizer; \
	elif [ "$(ASAN)" ]; then TARGET=AddressSanitizer; fi; \
	LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib:$(HOST_DIR)/lib:$(LD_LIBRARY_PATH) \
	HOSTDIR=$(HOST_DIR) \
	$(HOST_MAKE_ENV) \
	$(MAKE) -C $(@D) $$TARGET
endef

define HOST_GOOGLE_MCASTCAPTURE_COVERAGE_CMDS
	LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib:$(HOST_DIR)/lib:$(LD_LIBRARY_PATH) \
	HOSTDIR=$(HOST_DIR) \
	$(HOST_MAKE_ENV) \
	$(MAKE) -C $(@D) host-coverage
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
