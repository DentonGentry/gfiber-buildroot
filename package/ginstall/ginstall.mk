#############################################################
#
# GInstall (Google image installer)
#
#############################################################
GINSTALL_SITE=repo://vendor/google/platform
GINSTALL_DEPENDENCIES=python python-crypto host-python-crypto mtd
GINSTALL_INSTALL_TARGET=YES
GINSTALL_TEST=YES

define GINSTALL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0555 $(@D)/ginstall/ginstall.py $(TARGET_DIR)/bin/
endef

define GINSTALL_TEST_CMDS
	(cd $(@D)/ginstall; $(HOST_DIR)/usr/bin/python ginstall_test.py)
endef

$(eval $(call GENTARGETS))
