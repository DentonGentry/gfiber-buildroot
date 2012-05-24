#############################################################
#
# GInstall (Google image installer)
#
#############################################################
GINSTALL_SITE=repo://vendor/google/platform
GINSTALL_DEPENDENCIES=python mtd
GINSTALL_INSTALL_STAGING=NO
GINSTALL_INSTALL_TARGET=YES

define GINSTALL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0555 $(@D)/ginstall/ginstall.py $(TARGET_DIR)/bin/
endef

$(eval $(call GENTARGETS))
