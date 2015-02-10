#############################################################
#
# go_gonzojive_mdns
#
#############################################################
GO_GONZOJIVE_MDNS_VERSION = 137dbca2e45fd488fe17c6498374823aac888aa7
GO_GONZOJIVE_MDNS_SITE = https://github.com/gonzojive/mdns
GO_GONZOJIVE_MDNS_SITE_METHOD = git
GO_GONZOJIVE_MDNS_DEPENDENCIES = host-golang

define GO_GONZOJIVE_MDNS_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/gonzojive"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/gonzojive/mdns"
endef

GO_GONZOJIVE_MDNS_POST_PATCH_HOOKS += GO_GONZOJIVE_MDNS_FIX_PATH

$(eval $(call GENTARGETS))
