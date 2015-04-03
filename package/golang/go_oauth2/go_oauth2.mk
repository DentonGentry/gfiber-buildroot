#############################################################
#
# go_oauth
#
#############################################################
GO_OAUTH2_VERSION = c58fcf0ffc1c772aa2e1ee4894bc19f2649263b2
GO_OAUTH2_SITE = https://go.googlesource.com/oauth2
GO_OAUTH2_SITE_METHOD = git
GO_OAUTH2_DEPENDENCIES = host-golang

define GO_OAUTH2_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/golang.org/x"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/golang.org/x/oauth2"
endef

GO_OAUTH2_POST_PATCH_HOOKS += GO_OAUTH2_FIX_PATH

$(eval $(call GENTARGETS))
