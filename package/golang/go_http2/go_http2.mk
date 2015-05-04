#############################################################
#
# go_http2
#
#############################################################
GO_HTTP2_VERSION = 2609cc0d65ebda013df59aaa43b9b6f3a7a686f5
GO_HTTP2_SITE = https://github.com/bradfitz/http2
GO_HTTP2_SITE_METHOD = git
GO_HTTP2_DEPENDENCIES = host-golang

define GO_HTTP2_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/bradfitz"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/bradfitz/http2"
endef

GO_HTTP2_POST_PATCH_HOOKS += GO_HTTP2_FIX_PATH

$(eval $(call GENTARGETS))
