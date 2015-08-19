#############################################################
#
# gfex250
#
#############################################################

GOOGLE_GFEX250_SITE = repo://vendor/quantenna/drivers
GOOGLE_GFEX250_INSTALL_TARGET = YES

define GOOGLE_GFEX250_BUILD_CMDS
endef

define GOOGLE_GFEX250_INSTALL_TARGET_CMDS
	echo "Installing Quantenna scripts"
	cp -af $(@D)/scripts/. $(TARGET_DIR)/scripts
endef

$(eval $(call GENTARGETS))
