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

# Install Go protobuf compiler on host
define HOST_GO_PROTOBUF_INSTALL_CMDS
	mkdir -p "$(@D)/go/src/github.com/golang"
	ln -sT "$(@D)" "$(@D)/go/src/github.com/golang/protobuf"
        export $(GOLANG_ENV) ; \
	GOARCH= GOBIN="$(HOST_DIR)/usr/bin" GOPATH="$(@D)/go" \
	go install github.com/golang/protobuf/protoc-gen-go
endef

$(eval $(call GENTARGETS,host))
