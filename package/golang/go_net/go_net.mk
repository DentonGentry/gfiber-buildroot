#############################################################
#
# go_net
#
#############################################################
GO_NET_VERSION = f090b05f9bc9fe228db5cef02d762c4fe3a87547
GO_NET_SITE = https://go.googlesource.com/net
GO_NET_SITE_METHOD = git
GO_NET_DEPENDENCIES = host-golang

define GO_NET_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/golang.org/x"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/golang.org/x/net"
endef

GO_NET_POST_PATCH_HOOKS += GO_NET_FIX_PATH

$(eval $(call GENTARGETS))
