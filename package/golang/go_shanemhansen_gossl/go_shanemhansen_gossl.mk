#############################################################
#
# go_shanemhansen_gossl
#
###########################################################
GO_SHANEMHANSEN_GOSSL_VERSION = 5add35e26d283222a015a32c02b18579307d20b9
GO_SHANEMHANSEN_GOSSL_SITE = https://github.com/shanemhansen/gossl
GO_SHANEMHANSEN_GOSSL_SITE_METHOD = git
GO_SHANEMHANSEN_GOSSL_DEPENDENCIES = host-golang \
				     openssl

define GO_SHANEMHANSEN_GOSSL_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/shanemhansen"
	ln -sfT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/shanemhansen/gossl"
endef

GO_SHANEMHANSEN_GOSSL_POST_PATCH_HOOKS += GO_SHANEMHANSEN_GOSSL_FIX_PATH

$(eval $(call GENTARGETS))
