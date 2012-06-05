BCM_CFE_SITE=repo://vendor/broadcom/cfe
BCM_CFE_DEPENDENCIES=host-bcm_signing host-google_keystore_client host-google_signing
BCM_CFE_BUILD_DIR=$(@D)/RP_7425B0_CFE/CFE/bcm97425B0/build

SIGNING_DIR=$(BINARIES_DIR)/signing

ifeq ($(BR2_BRUNO_BCHP_VER),"B2")

define BCM_CFE_CONFIGURE_CMDS
	( \
		mkdir -m 700 -p $(SIGNING_DIR) && \
		cp $(@D)/tool/input_release_boot2_0.txt \
		$(@D)/tool/BCM7425B0_1_0_BSECK_NDGE_LE_Generic.bin \
		$(BINARIES_DIR)/signing && \
		$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,signing_private_key,$(SIGNING_DIR)/gfiber_private.pem) && \
		$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,signing_public_key_signature,$(SIGNING_DIR)/gfiber_key_sig.bin) \
	)
endef

define BCM_CFE_SIGNING_CMDS
	( \
		cd $(BCM_CFE_BUILD_DIR) && \
		./buildall.sh $(1) && \
		cp fsbl.bin ssbl.bin $(SIGNING_DIR) && \
		cd $(SIGNING_DIR) && \
		$(HOST_DIR)/usr/bin/brcm_sign_enc < input_release_boot2_0.txt && \
		openssl dgst -sign gfiber_private.pem -sha512 -binary -keyform \
		PEM cfe_signed.bin > cfe_signed.sig && \
		mv cfe_signed.bin $(BINARIES_DIR)/cfe_signed_$(1).bin && \
		mv cfe_signed.sig $(BINARIES_DIR)/cfe_signed_$(1).sig \
	)
endef

define BCM_CFE_BUILD_CMDS
	( \
		$(call BCM_CFE_SIGNING_CMDS,release) && \
		$(call BCM_CFE_SIGNING_CMDS,openbox) && \
		$(call BCM_CFE_SIGNING_CMDS,unlocked) && \
		$(HOST_GOOGLE_SIGNING_CLEANUP) \
	)
endef

endif

$(eval $(call GENTARGETS))
