#############################################################
#
# go_vincenospam_go_dbus
#
#############################################################
GO_VINCENOSPAM_GO_DBUS_VERSION = 284551d46c8bbb83f68850533c6247f588acdd61
GO_VINCENOSPAM_GO_DBUS_SITE = https://github.com/vincenospam/go.dbus
GO_VINCENOSPAM_GO_DBUS_SITE_METHOD = git
GO_VINCENOSPAM_GO_DBUS_DEPENDENCIES = host-golang

define GO_VINCENOSPAM_GO_DBUS_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/vincenospam/"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/vincenospam/go.dbus"
endef

GO_VINCENOSPAM_GO_DBUS_POST_PATCH_HOOKS += GO_VINCENOSPAM_GO_DBUS_FIX_PATH

$(eval $(call GENTARGETS))
