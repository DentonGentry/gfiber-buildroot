#############################################################
#
# go_sys
#
#############################################################
GO_SYS_VERSION = 342d6a85aa15bcd2ec54803cdffe90d52b6f35a7
GO_SYS_SITE = https://go.googlesource.com/sys
GO_SYS_SITE_METHOD = git
GO_SYS_DEPENDENCIES = host-golang

define GO_SYS_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/golang.org/x"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/golang.org/x/sys"
endef

GO_SYS_POST_PATCH_HOOKS += GO_SYS_FIX_PATH

$(eval $(call GENTARGETS))
