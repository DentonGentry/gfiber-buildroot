#############################################################
#
# go_google_api
#
#############################################################
GO_GOOGLE_API_VERSION = 82700a6837e5a35e4399ae2a57f1bd702a022f46
GO_GOOGLE_API_SITE = https://github.com/google/google-api-go-client
GO_GOOGLE_API_SITE_METHOD = git
GO_GOOGLE_API_DEPENDENCIES = host-golang

define GO_GOOGLE_API_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/google.golang.org"
	ln -sfT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/google.golang.org/api"
endef

GO_GOOGLE_API_POST_PATCH_HOOKS += GO_GOOGLE_API_FIX_PATH

$(eval $(call GENTARGETS))
