#############################################################
#
# go_tpm
#
#############################################################
GO_TPM_VERSION = 3ed59612cd51c13b6432538fb87b3c7ddc306781
GO_TPM_SITE = https://github.com/google/go-tpm
GO_TPM_SITE_METHOD = git
GO_TPM_DEPENDENCIES = host-golang

define GO_TPM_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/google"
	ln -sfT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/google/go-tpm"
endef

GO_TPM_POST_PATCH_HOOKS += GO_TPM_FIX_PATH

$(eval $(call GENTARGETS))
