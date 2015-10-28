#############################################################
#
# go_net
#
#############################################################
GO_NET_VERSION = 2cba614e8ff920c60240d2677bc019af32ee04e5
GO_NET_SITE = https://go.googlesource.com/net
GO_NET_SITE_METHOD = git
GO_NET_DEPENDENCIES = host-golang

define GO_NET_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/golang.org/x"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/golang.org/x/net"
endef

GO_NET_POST_PATCH_HOOKS += GO_NET_FIX_PATH

$(eval $(call GENTARGETS))
