BCM_SIGNING_SITE=repo://vendor/broadcom/cfe
BCM_SIGNING_INSTALL_IMAGES=YES
BCM_SIGNING_DEPENDENCIES = host-google_keystore_client

define HOST_BCM_SIGNING_INSTALL_CMDS
	$(INSTALL) -m 700 -D $(@D)/tool/brcm_sign_enc $(HOST_DIR)/usr/bin
endef

define BCM_SIGNING_INSTALL_IMAGES_CMDS
	mkdir -m 700 -p $(BINARIES_DIR)/signing
	$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,signing_private_key,$(BINARIES_DIR)/signing/gfiber_private.pem)
	chmod 700 $(BINARIES_DIR)/gfiber_private.txt
	$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,signing_public_key_signature,$(BINARIES_DIR)/signing/gfiber_key_sig.bin)
	chmod 700 $(BINARIES_DIR)/google_key_sig.bin

	$(INSTALL) -m 600 -D $(@D)/tool/BCM7425B0_1_0_BSECK_NDGE_LE_Generic.bin \
		$(BINARIES_DIR)/signing
	openssl rsa -in $(BINARIES_DIR)/signing/gfiber_private.pem -out \
		$(BINARIES_DIR)/signing/gfiber_public.pem -pubout
endef

define BCM_SIGNING_UNINSTALL_IMAGES_CMDS
	shred -u -z -n 5 $(BINARIES_DIR)/signing/*
	rmdir $(BINARIES_DIR)/signing
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
