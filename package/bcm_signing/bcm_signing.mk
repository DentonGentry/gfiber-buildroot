BCM_SIGNING_SITE=repo://vendor/broadcom/cfe

define HOST_BCM_SIGNING_INSTALL_CMDS
	$(INSTALL) -m 700 -D $(@D)/tool/brcm_sign_enc $(HOST_DIR)/usr/bin
	$(INSTALL) -m 600 -D $(@D)/tool/input_sign_cfe.txt $(BINARIES_DIR)
	$(INSTALL) -m 600 -D $(@D)/tool/input_sign_kernel.txt $(BINARIES_DIR)
	$(INSTALL) -m 600 -D $(@D)/tool/BCM7425B0_1_0_BSECK_NDGE_LE_Generic.bin $(BINARIES_DIR)
	(umask u=rwx,g=,o= && \
	cd /google/src/files/head/depot/google3 && \
	blaze --host_jvm_args=-Xmx256m run --forge -- \
		//isp/fiber/drm:drm_keystore_client \
		--key_type signing_private_key \
		--output $(BINARIES_DIR)/gfiber_private.txt && \
	blaze --host_jvm_args=-Xmx256m run --forge -- \
		//isp/fiber/drm:drm_keystore_client \
		--key_type signing_public_key_signature \
		--output $(BINARIES_DIR)/google_key_sig.bin)
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
