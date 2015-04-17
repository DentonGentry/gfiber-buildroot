#############################################################
#
# go_grpc
#
#############################################################
GO_GRPC_VERSION = 49257b21ef8b191d79fc732601e04eeb491b5bdc
GO_GRPC_SITE = https://github.com/grpc/grpc-go
GO_GRPC_SITE_METHOD = git
GO_GRPC_DEPENDENCIES = host-golang

define GO_GRPC_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/grpc"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/grpc/grpcgo"
endef

GO_GRPC_POST_PATCH_HOOKS += GO_GRPC_FIX_PATH

$(eval $(call GENTARGETS))
