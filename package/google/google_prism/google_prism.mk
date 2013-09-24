GOOGLE_PRISM_SITE=repo://vendor/google/prism
GOOGLE_PRISM_INSTALL_STAGING=YES
GOOGLE_PRISM_INSTALL_TARGET=YES
GOOGLE_PRISM_DEPENDENCIES=\
	host-py-mox \
	python \
	python-setuptools \

define GOOGLE_PRISM_BUILD_CMDS
	$(GPLAT_MAKE) PON_TYPE=$(BR2_PACKAGE_MV_APP_PON_TYPE) -C $(@D)
endef

define GOOGLE_PRISM_TEST_CMDS
	PYTHONPATH=$(HOST_PYTHONPATH):$(TARGET_DIR)/usr/catawampus \
	PYTHON=$(HOST_DIR)/usr/bin/python $(MAKE) -C $(@D) test
endef

define GOOGLE_PRISM_INSTALL_STAGING_CMDS
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(@D) install-libs
endef

define GOOGLE_PRISM_INSTALL_TARGET_CMDS
	$(GPLAT_MAKE) -C $(@D) install
endef

$(eval $(call GENTARGETS))
