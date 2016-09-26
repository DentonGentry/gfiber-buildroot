GOOGLE_DART_VM_SITE=https://github.com/dart-lang/sdk.git
GOOGLE_DART_VM_SITE_METHOD=gclient
GOOGLE_DART_VM_VERSION=b40c20bfbccd0e4d98d194b9d362d04a9f7c91f3
GOOGLE_DART_VM_INSTALL_STAGING=YES

RELEASE=Product
ifeq ($(ARCH),arm)
GOOGLE_DART_VM_BTYPE=${RELEASE}XARM
else ifeq ($(ARCH),armeb)
GOOGLE_DART_VM_BTYPE=${RELEASE}XARM
else ifeq ($(ARCH),mips)
GOOGLE_DART_VM_BTYPE=${RELEASE}XMIPS
else ifeq ($(ARCH),mipsel)
GOOGLE_DART_VM_BTYPE=${RELEASE}XMIPS
else ifeq ($(ARCH),i386)
GOOGLE_DART_VM_BTYPE=${RELEASE}IA32
else ifeq ($(ARCH),x86_64)
GOOGLE_DART_VM_BTYPE=${RELEASE}X64
else
$(error Unsupported architecture '$(ARCH)')
endif

GOOGLE_DART_VM_MAKE_VARS=\
BUILDTYPE=$(GOOGLE_DART_VM_BTYPE) \
NM.target="$(TARGET_NM)" \
CC.target="$(TARGET_CC)" \
LINK.target="$(TARGET_CXX)" \
CXX.target="$(TARGET_CXX)" \
AR.target="$(TARGET_AR)"

define GOOGLE_DART_VM_BUILD_CMDS
	$(MAKE) -C $(BUILD_DIR)/$($(PKG)_BASE_NAME)/sdk $(GOOGLE_DART_VM_MAKE_VARS) runtime
	cp $(BUILD_DIR)/$($(PKG)_BASE_NAME)/sdk/out/$(GOOGLE_DART_VM_BTYPE)/dart $(BUILD_DIR)/$($(PKG)_BASE_NAME)/sdk/out/$(GOOGLE_DART_VM_BTYPE)/dart_nostrip
	$(TARGET_STRIP) $(BUILD_DIR)/$($(PKG)_BASE_NAME)/sdk/out/$(GOOGLE_DART_VM_BTYPE)/dart
endef


define GOOGLE_DART_VM_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/local/include
	$(INSTALL) -D -m 0644 $(BUILD_DIR)/$($(PKG)_BASE_NAME)/sdk/runtime/include/dart_api.h $(STAGING_DIR)/usr/local/include
	$(INSTALL) -D -m 0644 $(BUILD_DIR)/$($(PKG)_BASE_NAME)/sdk/runtime/include/dart_native_api.h $(STAGING_DIR)/usr/local/include
	$(INSTALL) -D -m 0644 $(BUILD_DIR)/$($(PKG)_BASE_NAME)/sdk/runtime/include/dart_mirrors_api.h $(STAGING_DIR)/usr/local/include
endef


define GOOGLE_DART_VM_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(BUILD_DIR)/$($(PKG)_BASE_NAME)/sdk/out/$(GOOGLE_DART_VM_BTYPE)/dart $(TARGET_DIR)/usr/bin
endef

$(eval $(call GENTARGETS))
