#############################################################
#
# go_miekg_dns
#
#############################################################
GO_MIEKG_DNS_VERSION = b65f52f3f0dd1afa25cbbf63f8e7eb15fb5c0641
GO_MIEKG_DNS_SITE = https://github.com/miekg/dns
GO_MIEKG_DNS_SITE_METHOD = git
GO_MIEKG_DNS_DEPENDENCIES = host-golang

define GO_MIEKG_DNS_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/miekg"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/miekg/dns"
endef

GO_MIEKG_DNS_POST_PATCH_HOOKS += GO_MIEKG_DNS_FIX_PATH

$(eval $(call GENTARGETS))
