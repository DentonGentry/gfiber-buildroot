#############################################################
#
# Catawampus tr-69 agent
#
#############################################################
GOOGLE_CATAWAMPUS_SITE=repo://vendor/google/catawampus
GOOGLE_CATAWAMPUS_DEPENDENCIES=python
GOOGLE_CATAWAMPUS_INSTALL_STAGING=NO
GOOGLE_CATAWAMPUS_INSTALL_TARGET=YES

define GOOGLE_CATAWAMPUS_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_CATAWAMPUS_INSTALL_TARGET_CMDS
	(cd $(@D); DSTDIR=$(TARGET_DIR)/usr/catawampus/ make install)
endef

$(eval $(call GENTARGETS,package/google,google_catawampus))
