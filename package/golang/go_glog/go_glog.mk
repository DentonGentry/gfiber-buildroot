#############################################################
#
# go_glog
#
#############################################################
GO_GLOG_VERSION = 44145f04b68cf362d9c4df2182967c2275eaefed
GO_GLOG_SITE = https://github.com/golang/glog
GO_GLOG_SITE_METHOD = git
GO_GLOG_DEPENDENCIES = host-golang

define GO_GLOG_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/golang"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/golang/glog"
endef

GO_GLOG_POST_PATCH_HOOKS += GO_GLOG_FIX_PATH

$(eval $(call GENTARGETS))
