#############################################################
#
# go_guelfey_go_dbus
#
#############################################################
GO_GUELFEY_GO_DBUS_VERSION = f6a3a2366cc39b8479cadc499d3c735fb10fbdda
GO_GUELFEY_GO_DBUS_SITE = https://github.com/guelfey/go.dbus
GO_GUELFEY_GO_DBUS_SITE_METHOD = git
GO_GUELFEY_GO_DBUS_DEPENDENCIES = host-golang

define GO_GUELFEY_GO_DBUS_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/guelfey/"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/guelfey/go.dbus"
endef

GO_GUELFEY_GO_DBUS_POST_PATCH_HOOKS += GO_GUELFEY_GO_DBUS_FIX_PATH

$(eval $(call GENTARGETS))
