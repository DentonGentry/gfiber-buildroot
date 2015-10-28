#############################################################
#
# go_protobuf
#
#############################################################
GO_PROTOBUF_VERSION = e228b1ac337584c4ce21b022312332ca6a5532ff
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
