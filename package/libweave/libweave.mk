#############################################################
#
# libweave
#
#############################################################

LIBWEAVE_VERSION = weave-release-1.2
LIBWEAVE_SITE = https://weave.googlesource.com/weave/libweave
LIBWEAVE_SITE_METHOD = git
LIBWEAVE_INSTALL_STAGING = YES
LIBWEAVE_DEPENDENCIES = gtest
LIBWEAVE_BUILD_MODE = Release

define LIBWEAVE_CONFIGURE_CMDS
	ln -fs "$(STAGING_DIR)/usr/include/gtest" "$(@D)"/include
endef

define LIBWEAVE_BUILD_CMDS
        export PATH=$(TARGET_PATH):$$PATH; \
	BUILD_MODE=$(LIBWEAVE_BUILD_MODE) \
        $(MAKE) -C "$(@D)" -e CC="$(TARGET_CC)" -e CXX="$(TARGET_CXX)" out/$(LIBWEAVE_BUILD_MODE)/libweave.so
endef

define LIBWEAVE_INSTALL_STAGING_CMDS
	ln -sf "$(@D)/include/weave" "$(STAGING_DIR)/usr/include"
	ln -sf "$(@D)/third_party" "$(STAGING_DIR)/usr/include/weave"
	$(INSTALL) -D "$(@D)/out/$(LIBWEAVE_BUILD_MODE)/libweave.so" "$(STAGING_DIR)/usr/lib/libweave.so"
endef

define LIBWEAVE_INSTALL_TARGET_CMDS
	$(INSTALL) -D "$(@D)/out/$(LIBWEAVE_BUILD_MODE)/libweave.so" "$(TARGET_DIR)/usr/lib/libweave.so"
endef

$(eval $(call GENTARGETS))
