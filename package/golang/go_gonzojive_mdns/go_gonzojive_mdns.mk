#############################################################
#
# go_gonzojive_mdns
#
#############################################################
GO_GONZOJIVE_MDNS_VERSION = 1810874fc7df1cbfe78c9b8e393d9cb4de4c6744
GO_GONZOJIVE_MDNS_SITE = https://github.com/gonzojive/mdns
GO_GONZOJIVE_MDNS_SITE_METHOD = git
GO_GONZOJIVE_MDNS_DEPENDENCIES = host-golang

define GO_GONZOJIVE_MDNS_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/gonzojive"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/gonzojive/mdns"
endef

GO_GONZOJIVE_MDNS_POST_PATCH_HOOKS += GO_GONZOJIVE_MDNS_FIX_PATH

$(eval $(call GENTARGETS))
