BCM_SIGNING_SITE=repo://vendor/broadcom/cfe
BCM_SIGNING_INSTALL_IMAGES=YES

define HOST_BCM_SIGNING_INSTALL_CMDS
	$(INSTALL) -m 700 -D $(@D)/tool/brcm_sign_enc $(HOST_DIR)/usr/bin
endef

define BCM_SIGNING_INSTALL_IMAGES_CMDS
	$(INSTALL) -m 600 -D $(@D)/tool/BCM7425B0_1_0_BSECK_NDGE_LE_Generic.bin \
		$(BINARIES_DIR)/signing/BCM7425B0_1_0_BSECK_NDGE_LE_Generic.bin
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
