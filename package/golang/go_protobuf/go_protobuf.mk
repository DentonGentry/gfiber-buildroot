#############################################################
#
# go_protobuf
#
#############################################################
GO_PROTOBUF_VERSION = 5677a0e3d5e89854c9974e1256839ee23f8233ca
GO_PROTOBUF_SITE = https://github.com/golang/protobuf
GO_PROTOBUF_SITE_METHOD = git
GO_PROTOBUF_DEPENDENCIES = host-golang

define GO_PROTOBUF_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/golang"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/golang/protobuf"
endef

GO_PROTOBUF_POST_PATCH_HOOKS += GO_PROTOBUF_FIX_PATH

$(eval $(call GENTARGETS))
