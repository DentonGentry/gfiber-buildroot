#############################################################
#
# go_goczmq
#
#############################################################
GO_GOCZMQ_VERSION = 8faac53b266836259913aaece62beff3af6452fc
GO_GOCZMQ_SITE = https://github.com/zeromq/goczmq
GO_GOCZMQ_SITE_METHOD = git
GO_GOCZMQ_DEPENDENCIES = host-golang czmq libsodium host-czmq host-libsodium

define GO_GOCZMQ_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/zeromq"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/zeromq/goczmq"
endef

GO_GOCZMQ_POST_PATCH_HOOKS += GO_GOCZMQ_FIX_PATH

$(eval $(call GENTARGETS))
