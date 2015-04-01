#############################################################
#
# go_oauth
#
#############################################################
GO_OAUTH2_VERSION = 11c60b6f71a6ad48ed6f93c65fa4c6f9b1b5b46a
GO_OAUTH2_SITE = https://github.com/golang/oauth2
GO_OAUTH2_SITE_METHOD = git
GO_OAUTH2_DEPENDENCIES = host-golang

define GO_OAUTH2_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/golang"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/golang/oauth2"
endef

GO_OAUTH2_POST_PATCH_HOOKS += GO_OAUTH2_FIX_PATH

$(eval $(call GENTARGETS))
