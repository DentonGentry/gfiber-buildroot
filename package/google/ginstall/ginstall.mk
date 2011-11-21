#############################################################
#
# GInstall (Google image installer)
#
#############################################################
GOOGLE_GINSTALL_SITE=repo://vendor/google/platform
GOOGLE_GINSTALL_DEPENDENCIES=python mtd
GOOGLE_GINSTALL_INSTALL_STAGING=NO
GOOGLE_GINSTALL_INSTALL_TARGET=YES

define GOOGLE_GINSTALL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0555 $(@D)/bruno/ginstall/ginstall.py $(TARGET_DIR)/bin/
endef

$(eval $(call GENTARGETS,package/google,google_ginstall))
