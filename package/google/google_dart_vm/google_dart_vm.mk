GOOGLE_DART_VM_SITE=http://dart.googlecode.com/svn/branches/bleeding_edge/deps/standalone.deps
GOOGLE_DART_VM_SITE_METHOD=gclient
GOOGLE_DART_VM_VERSION=28355

GOOGLE_DART_VM_MAKE_VARS=\
BUILDTYPE=ReleaseMIPS \
NM.target="$(TARGET_NM)" \
CC.target="$(TARGET_CC)" \
LINK.target="$(TARGET_CXX)" \
CXX.target="$(TARGET_CXX)" \
AR.target="$(TARGET_AR)"

define GOOGLE_DART_VM_BUILD_CMDS
	$(MAKE) -C $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/runtime $(GOOGLE_DART_VM_MAKE_VARS)
	$(TARGET_STRIP) $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/runtime/out/ReleaseMIPS/dart
endef


define GOOGLE_DART_VM_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(BUILD_DIR)/$($(PKG)_BASE_NAME)/dart/runtime/out/ReleaseMIPS/dart $(TARGET_DIR)/usr/bin
endef

$(eval $(call GENTARGETS))
