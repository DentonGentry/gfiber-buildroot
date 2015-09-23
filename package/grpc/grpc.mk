GRPC_VERSION=release-0_11_0
GRPC_SITE=https://github.com/grpc/grpc/archive/
GRPC_SOURCE=grpc-$(GRPC_VERSION).tar.gz
GRPC_INSTALL_STAGING = YES
GRPC_DEPENDENCIES=google_gflags openssl host-protobuf protobuf zlib

GRPC_CROSS_MAKE_OPT_BASE = \
	CC="$(TARGET_CC)" \
	CXX="$(TARGET_CXX)" \
	LD="$(TARGET_CC)" \
	LDXX="$(TARGET_CXX)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	STRIP="$(TARGET_STRIP)"

GRPC_MAKE_OPT = \
	$(GRPC_CROSS_MAKE_OPT_BASE) \
	prefix="$(TARGET_DIR)/usr"

GRPC_INSTALL_STAGING_OPT = \
	$(GRPC_CROSS_MAKE_OPT_BASE) \
	prefix="$(STAGING_DIR)/usr"

HOST_GRPC_MAKE_OPT = \
	CFLAGS="$(HOST_CFLAGS)" \
	LDFLAGS="$(HOST_LDFLAGS)" \
	prefix="$(HOST_DIR)/usr"

define GRPC_BUILD_CMDS
	$(MAKE) $(GRPC_MAKE_OPT) -C $(@D) static shared
endef

define GRPC_INSTALL_TARGET_CMDS
  # Could be install-static and install-shared, but grpc is currently missing
  # the install-shared target.
	$(MAKE) $(GRPC_MAKE_OPT) -C $(@D) install-static install-shared_c install-shared_cxx
endef

define GRPC_INSTALL_STAGING_CMDS
	$(MAKE) $(GRPC_INSTALL_STAGING_OPT) -C $(@D) install_c install_cxx
endef

define HOST_GRPC_BUILD_CMDS
	$(MAKE) $(HOST_GRPC_MAKE_OPT) -C $(@D) plugins
endef

define HOST_GRPC_INSTALL_CMDS
	$(MAKE) $(HOST_GRPC_MAKE_OPT) -C $(@D) install-plugins
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))

