BCM_SIGNING_SITE=repo://vendor/broadcom/cfe
BCM_SIGNING_INSTALL_IMAGES=YES

define HOST_BCM_SIGNING_INSTALL_CMDS
	$(INSTALL) -m 700 -D $(@D)/tool/brcm_sign_enc $(HOST_DIR)/usr/bin
endef

define BCM_SIGNING_INSTALL_IMAGES_CMDS
	(umask u=rwx,g=,o= && \
	mkdir -p $(BINARIES_DIR)/signing && \
	cd /google/src/files/head/depot/google3 && \
	blaze --host_jvm_args=-Xmx256m run --forge -- \
		//isp/fiber/drm:drm_keystore_client \
		--key_type signing_private_key \
		--output $(BINARIES_DIR)/signing/gfiber_private.pem && \
	blaze --host_jvm_args=-Xmx256m run --forge -- \
		//isp/fiber/drm:drm_keystore_client \
		--key_type signing_public_key_signature \
		--output $(BINARIES_DIR)/signing/gfiber_key_sig.bin)
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
