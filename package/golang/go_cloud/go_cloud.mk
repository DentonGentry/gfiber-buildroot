#############################################################
#
# go_cloud
#
#############################################################
GO_CLOUD_VERSION = 92dc777f99fe90dc61ef98e34078f1efe2f63134
GO_CLOUD_SITE = https://github.com/GoogleCloudPlatform/gcloud-golang
GO_CLOUD_SITE_METHOD = git
GO_CLOUD_DEPENDENCIES = host-golang

define GO_CLOUD_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/google.golang.org/"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/google.golang.org/cloud"
endef

GO_CLOUD_POST_PATCH_HOOKS += GO_CLOUD_FIX_PATH

$(eval $(call GENTARGETS))
