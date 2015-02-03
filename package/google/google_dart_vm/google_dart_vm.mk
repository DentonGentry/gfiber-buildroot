GOOGLE_DART_VM_SITE=http://dart.googlecode.com/svn/branches/1.8/deps/standalone.deps
GOOGLE_DART_VM_SITE_METHOD=gclient
GOOGLE_DART_VM_VERSION=42828
GOOGLE_DART_VM_INSTALL_STAGING=YES

ifeq ($(ARCH),arm)
GOOGLE_DART_VM_BTYPE=ReleaseXARM
else ifeq ($(ARCH),armeb)
GOOGLE_DART_VM_BTYPE=ReleaseXARM
else ifeq ($(ARCH),mips)
GOOGLE_DART_VM_BTYPE=ReleaseXMIPS
else ifeq ($(ARCH),mipsel)
GOOGLE_DART_VM_BTYPE=ReleaseXMIPS
else ifeq ($(ARCH),i386)
GOOGLE_DART_VM_BTYPE=ReleaseIA32
else ifeq ($(ARCH),x86_64)
GOOGLE_DART_VM_BTYPE=ReleaseX64
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
	$(MAKE) -C $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart $(GOOGLE_DART_VM_MAKE_VARS)
	cp $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/out/$(GOOGLE_DART_VM_BTYPE)/dart $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/out/$(GOOGLE_DART_VM_BTYPE)/dart_nostrip
	$(TARGET_STRIP) $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/out/$(GOOGLE_DART_VM_BTYPE)/dart
endef


define GOOGLE_DART_VM_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/local/include
	$(INSTALL) -D -m 0644 $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/runtime/include/dart_api.h $(STAGING_DIR)/usr/local/include
	$(INSTALL) -D -m 0644 $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/runtime/include/dart_native_api.h $(STAGING_DIR)/usr/local/include
	$(INSTALL) -D -m 0644 $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/runtime/include/dart_mirrors_api.h $(STAGING_DIR)/usr/local/include
endef


define GOOGLE_DART_VM_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/out/$(GOOGLE_DART_VM_BTYPE)/dart $(TARGET_DIR)/usr/bin
endef

$(eval $(call GENTARGETS))
