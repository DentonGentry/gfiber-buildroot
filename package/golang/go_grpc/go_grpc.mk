#############################################################
#
# go_grpc
#
#############################################################
GO_GRPC_VERSION = 13edeeffdea7a41d5aad96c28deb4c7bd01a9397
GO_GRPC_SITE = https://github.com/grpc/grpc-go
GO_GRPC_SITE_METHOD = git
GO_GRPC_DEPENDENCIES = host-golang go_http2

define GO_GRPC_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/google.golang.org/"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/google.golang.org/grpc"
endef

GO_GRPC_POST_PATCH_HOOKS += GO_GRPC_FIX_PATH

$(eval $(call GENTARGETS))
