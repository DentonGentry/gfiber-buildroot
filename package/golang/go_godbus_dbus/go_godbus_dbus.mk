#############################################################
#
# go_godbus_dbus
#
#############################################################
GO_GODBUS_DBUS_VERSION = 41608027bdce7bfa8959d653a00b954591220e67
GO_GODBUS_DBUS_SITE = https://github.com/godbus/dbus
GO_GODBUS_DBUS_SITE_METHOD = git
GO_GODBUS_DBUS_DEPENDENCIES = host-golang

define GO_GODBUS_DBUS_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/godbus/"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/godbus/dbus"
endef

GO_GODBUS_DBUS_POST_PATCH_HOOKS += GO_GODBUS_DBUS_FIX_PATH

$(eval $(call GENTARGETS))
