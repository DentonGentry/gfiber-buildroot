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
	(cd $(@D); DSTDIR=$(TARGET_DIR)/usr/catawampus/ make install)
endef

$(eval $(call GENTARGETS,package,catawampus))
