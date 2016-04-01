BCM_OEMCRYPTO_SITE=repo://vendor/broadcom/OEMCrypto
BCM_OEMCRYPTO_CONFIGURE_CMDS=ln -sf $(@D)/BSEAV $(BUILD_DIR)/OEMCrypto
BCM_OEMCRYPTO_DEPENDENCIES=bcm_nexus bcm_bseav

define BCM_OEMCRYPTO_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) COMPILE_WVSOURCE=y USE_CURL=y -C $(@D)/../OEMCrypto/lib/security/third_party/widevine/CENC21 report
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) COMPILE_WVSOURCE=y USE_CURL=y -C $(@D)/../OEMCrypto/lib/security/third_party/widevine/CENC21 oemcrypto oec_unittest
endef

$(eval $(call GENTARGETS))
