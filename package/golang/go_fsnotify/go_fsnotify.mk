#############################################################
#
# go_fsnotify
#
#############################################################
GO_FSNOTIFY_VERSION = 96c060f6a6b7e0d6f75fddd10efeaca3e5d1bcb0
GO_FSNOTIFY_SITE = https://github.com/go-fsnotify/fsnotify
GO_FSNOTIFY_SITE_METHOD = git
GO_FSNOTIFY_DEPENDENCIES = host-golang

define GO_FSNOTIFY_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/go-fsnotify/"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/go-fsnotify/fsnotify"
endef

GO_FSNOTIFY_POST_PATCH_HOOKS += GO_FSNOTIFY_FIX_PATH

$(eval $(call GENTARGETS))

