#############################################################
#
# go_golua
#
#############################################################
GO_GOLUA_VERSION = d4351ab17557c115aab48c2d62d9a4f98710dee2
GO_GOLUA_SITE = https://github.com/aarzilli/golua
GO_GOLUA_SITE_METHOD = git
GO_GOLUA_DEPENDENCIES = host-golang

define GO_GOLUA_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/aarzilli"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/aarzilli/golua"
endef

GO_GOLUA_POST_PATCH_HOOKS += GO_GOLUA_FIX_PATH

define GO_GOLUA_CUSTOM_PATCHES
	support/scripts/apply-patches.sh $(@D) $($(PKG)_DIR_PREFIX)/$(RAWNAME) \
		\*.patch
endef

GO_GOLUA_POST_PATCH_HOOKS += GO_GOLUA_CUSTOM_PATCHES


$(eval $(call GENTARGETS))
