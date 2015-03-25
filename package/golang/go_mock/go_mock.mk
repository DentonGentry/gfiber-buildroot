#############################################################
#
# go_mock
#
#############################################################
GO_MOCK_VERSION = e033c7513ca3
GO_MOCK_SITE = https://code.google.com/p/gomock/
GO_MOCK_SITE_METHOD = git
GO_MOCK_DEPENDENCIES = host-golang

define GO_MOCK_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/code.google.com/p"
	ln -sfT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/code.google.com/p/gomock"
endef

HOST_GO_MOCK_POST_PATCH_HOOKS += GO_MOCK_FIX_PATH

define HOST_GO_MOCK_INSTALL_CMDS
	export $(GOLANG_ENV) ; \
	GOARCH= GOBIN="$(HOST_DIR)/usr/bin" go install code.google.com/p/gomock/mockgen
endef

define HOST_GO_MOCK_CLEAN_CMDS
	rm -f "$(HOST_DIR)/usr/bin/mockgen"
endef

$(eval $(call GENTARGETS,host))
