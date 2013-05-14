#############################################################
#
# Catawampus tr-69 agent
#
#############################################################
CATAWAMPUS_SITE=repo://vendor/google/catawampus
CATAWAMPUS_DEPENDENCIES=python py-curl host-py-mox host-python host-py-yaml
CATAWAMPUS_DEPENDENCIES+=python-netifaces
CATAWAMPUS_INSTALL_STAGING=NO
CATAWAMPUS_INSTALL_TARGET=YES

define CATAWAMPUS_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS) PYTHON=$(HOST_DIR)/usr/bin/python $(MAKE) -C $(@D)
endef

define CATAWAMPUS_INSTALL_TARGET_CMDS
	DSTDIR=$(TARGET_DIR)/usr/catawampus/ PYTHON=$(HOST_DIR)/usr/bin/python \
		   $(MAKE) -C $(@D) install
endef

define CATAWAMPUS_REMOVE_SURPLUS_FILES
	for i in `find $(TARGET_DIR)/usr/catawampus/ -type f -name *.py` ; do \
		rm -f $$i ; \
	done
endef

CATAWAMPUS_POST_INSTALL_TARGET_HOOKS += CATAWAMPUS_REMOVE_SURPLUS_FILES

define CATAWAMPUS_TEST_CMDS
	PYTHONPATH=$(HOST_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	$(MAKE) -C $(@D) test
endef

$(eval $(call GENTARGETS))
