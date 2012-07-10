#############################################################
#
# Catawampus tr-69 agent
#
#############################################################
CATAWAMPUS_SITE=repo://vendor/google/catawampus
CATAWAMPUS_DEPENDENCIES=python py-curl
CATAWAMPUS_INSTALL_STAGING=NO
CATAWAMPUS_INSTALL_TARGET=YES

define CATAWAMPUS_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define CATAWAMPUS_INSTALL_TARGET_CMDS
	DSTDIR=$(TARGET_DIR)/usr/catawampus/ $(MAKE) -C $(@D) install
endef

define CATAWAMPUS_TEST_CMDS
	$(MAKE) -C $(@D) test
endef

$(eval $(call GENTARGETS))
