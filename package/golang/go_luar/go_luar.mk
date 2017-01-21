#############################################################
#
# go_luar
#
#############################################################
GO_LUAR_VERSION = eee0f827bb1339b20856087fb396604f3994a250
GO_LUAR_SITE = https://github.com/stevedonovan/luar/
GO_LUAR_SITE_METHOD = git
GO_LUAR_DEPENDENCIES = host-golang go_golua

define GO_LUAR_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/stevedonovan/"
	ln -sfT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/stevedonovan/luar"
endef

GO_LUAR_POST_PATCH_HOOKS += GO_LUAR_FIX_PATH

define GO_LUAR_CUSTOM_PATCHES
	support/scripts/apply-patches.sh $(@D) $($(PKG)_DIR_PREFIX)/$(RAWNAME) \
		\*.patch
endef

GO_LUAR_POST_PATCH_HOOKS += GO_LUAR_CUSTOM_PATCHES

$(eval $(call GENTARGETS))
