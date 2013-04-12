PRISM_SITE=repo://vendor/google/platform

PRISM_INSTALL_STAGING=YES
PRISM_INSTALL_TARGET=YES
PRISM_INSTALL_IMAGES=YES

PRISM_DEPENDENCIES=python py-setuptools host-py-yaml host-py-mox host-i2c-tools

define PRISM_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS) \
	$(MAKE) -C $(@D)/cmds && \
	PYTHONPATH=$(TARGET_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	CROSS_COMPILE=$(TARGET_CROSS) \
	$(MAKE) -C $(@D)/prism
endef

define PRISM_TEST_CMDS
	PYTHONPATH=$(HOST_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	$(MAKE) -C $(@D)/prism test
endef

define PRISM_INSTALL_TARGET_CMDS
	$(call GENIMAGEVERSION,prism)
	DESTDIR=$(TARGET_DIR) $(MAKE) -C $(@D)/cmds install && \
	HOSTPYTHONPATH=$(HOST_PYTHONPATH) \
	PYTHONPATH=$(TARGET_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	HOSTDIR=$(HOST_DIR) \
	DESTDIR=$(TARGET_DIR) $(MAKE) -C $(@D)/prism install
endef

$(eval $(call GENTARGETS))
