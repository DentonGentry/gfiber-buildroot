#############################################################
#
# go_cron
#
#############################################################
GO_CRON_VERSION = 67823cd24dece1b04cced3a0a0b3ca2bc84d875e
GO_CRON_SITE = https://github.com/robfig/cron
GO_CRON_SITE_METHOD = git
GO_CRON_DEPENDENCIES = host-golang

define GO_CRON_FIX_PATH
	mkdir -p "$(BUILD_DIR)/go_pkgs/src/github.com/robfig/"
	ln -sT "$(@D)" "$(BUILD_DIR)/go_pkgs/src/github.com/robfig/cron"
endef

GO_CRON_POST_PATCH_HOOKS += GO_CRON_FIX_PATH

$(eval $(call GENTARGETS))

