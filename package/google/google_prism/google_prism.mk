GOOGLE_PRISM_SITE=repo://vendor/google/prism

GOOGLE_PRISM_INSTALL_STAGING=YES
GOOGLE_PRISM_INSTALL_TARGET=YES
GOOGLE_PRISM_INSTALL_IMAGES=YES

GOOGLE_PRISM_DEPENDENCIES=python py-setuptools host-py-yaml host-py-mox host-i2c-tools

define GOOGLE_PRISM_BUILD_CMDS
	$(GPLAT_MAKE) -C $(@D)
endef

define GOOGLE_PRISM_TEST_CMDS
	$(GPLAT_MAKE) -C $(@D) test
endef

define GOOGLE_PRISM_INSTALL_TARGET_CMDS
	$(call GENIMAGEVERSION,prism)
	$(GPLAT_MAKE) -C $(@D) install
endef

$(eval $(call GENTARGETS))
