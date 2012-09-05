BCM_SIGNING_SITE=repo://vendor/broadcom/cfe
BCM_SIGNING_INSTALL_IMAGES=YES

define HOST_BCM_SIGNING_INSTALL_CMDS
	$(INSTALL) -m 700 -D $(@D)/tool/brcm_sign_enc $(HOST_DIR)/usr/bin
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
