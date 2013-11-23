GOOGLE_DART_VM_SITE=http://dart.googlecode.com/svn/branches/bleeding_edge/deps/standalone.deps
GOOGLE_DART_VM_SITE_METHOD=gclient
GOOGLE_DART_VM_VERSION=30104
GOOGLE_DART_VM_INSTALL_STAGING=YES

ifeq ($(ARCH),arm)
BTYPE=ReleaseARM
else
BTYPE=ReleaseMIPS
endif

GOOGLE_DART_VM_MAKE_VARS=\
BUILDTYPE=$(BTYPE) \
NM.target="$(TARGET_NM)" \
CC.target="$(TARGET_CC)" \
LINK.target="$(TARGET_CXX)" \
CXX.target="$(TARGET_CXX)" \
AR.target="$(TARGET_AR)"

define GOOGLE_DART_VM_BUILD_CMDS
	$(MAKE) -C $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart $(GOOGLE_DART_VM_MAKE_VARS)
	$(TARGET_STRIP) $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/out/$(BTYPE)/dart
endef


define GOOGLE_DART_VM_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/local/include
	$(INSTALL) -D -m 0644 $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/runtime/include/dart_api.h $(STAGING_DIR)/usr/local/include
	$(INSTALL) -D -m 0644 $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/runtime/include/dart_native_api.h $(STAGING_DIR)/usr/local/include
	$(INSTALL) -D -m 0644 $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/runtime/include/dart_mirrors_api.h $(STAGING_DIR)/usr/local/include
endef


define GOOGLE_DART_VM_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/out/$(BTYPE)/dart $(TARGET_DIR)/usr/bin
endef

$(eval $(call GENTARGETS))
