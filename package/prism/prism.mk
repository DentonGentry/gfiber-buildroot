PRISM_SITE=repo://vendor/google/platform

PRISM_INSTALL_STAGING=YES
PRISM_INSTALL_TARGET=YES
PRISM_INSTALL_IMAGES=YES

PRISM_DEPENDENCIES=python py-setuptools host-py-yaml host-py-mox host-i2c-tools

define PRISM_BUILD_CMDS
	$(BRUNO_MAKE) -C $(@D)/cmds && \
	$(BRUNO_MAKE) -C $(@D)/prism
endef

define PRISM_TEST_CMDS
	$(BRUNO_MAKE) -C $(@D)/prism test
endef

define PRISM_INSTALL_TARGET_CMDS
	$(call GENIMAGEVERSION,prism)
	$(BRUNO_MAKE) -C $(@D)/prism install
endef

$(eval $(call GENTARGETS))
