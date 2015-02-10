#############################################################
#
# go_google_api
#
#############################################################
GO_GOOGLE_API_VERSION = 9a9ac72c034413761ee433e6de44f5163626b7b8
GO_GOOGLE_API_SITE = https://github.com/google/google-api-go-client
GO_GOOGLE_API_SITE_METHOD = git
GO_GOOGLE_API_DEPENDENCIES = host-golang

define GO_GOOGLE_API_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/google.golang.org"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/google.golang.org/api"
endef

GO_GOOGLE_API_POST_PATCH_HOOKS += GO_GOOGLE_API_FIX_PATH

$(eval $(call GENTARGETS))
