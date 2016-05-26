#############################################################
#
# google_signing (signing related code)
#
#############################################################
GOOGLE_SIGNING_SITE_METHOD=null
GOOGLE_SIGNING_DEPENDENCIES=host-gtest host-py-openssl \
			    google_platform \
			    host-google_platform \
			    host-google_keystore_client

ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
ifneq ($(BR2_PACKAGE_GOOGLE_UNSIGNED),y)
ifneq ($(BR2_TARGET_GENERIC_PLATFORM_NAME),"gfsc100")
GOOGLE_SIGNING_DEPENDENCIES += bcm_signing bcm_bolt_signing host-bcm_signing
endif
endif
endif

HOST_GOOGLE_SIGNING_TEST=YES
SIGNING_DIR=$(BINARIES_DIR)/signing

ifeq ($(BR2_TARGET_GENERIC_PLATFORM_NAME),"gfsc100")
KEYSTORE_CONFIG_ID=SPACECAST
else
KEYSTORE_CONFIG_ID=GFIBER_DRM
endif

SIGNING_FLAG=""
ifeq ($(BR2_PACKAGE_GOOGLE_PROD)$(BR2_PACKAGE_GOOGLE_UNSIGNED),y)
define HOST_GOOGLE_SIGNING_RETRIEVE_KEY
	(mkdir -m 700 -p $(SIGNING_DIR); \
	$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,signing_private_key,$(SIGNING_DIR)/gfiber_private.pem); \
	$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,gfhd254_key0_private,$(SIGNING_DIR)/gfhd254_private.pem))
endef
SIGNING_FLAG="-s"
GOOGLE_KEYSTORE_CLIENT_NEEDS_KEYS += \
	signing_private_key \
	signing_public_key_signature
else
define HOST_GOOGLE_SIGNING_RETRIEVE_KEY
	echo 'Skip retrieving signing key...'
endef
endif

define HOST_GOOGLE_SIGNING_CLEANUP
	if [ -d "$(SIGNING_DIR)" ]; then \
		shred -f -u -z -n 5 $(SIGNING_DIR)/*; \
		rm -rf $(SIGNING_DIR); \
	fi
endef

ifneq ($(BR2_PACKAGE_GOOGLE_UNSIGNED),y)
define HOST_GOOGLE_SIGNING_SIGN
	($(HOST_GOOGLE_SIGNING_RETRIEVE_KEY) && \
		$(HOST_DIR)/usr/bin/python $(HOST_DIR)/usr/sbin/repack.py \
		-o $(HOST_DIR) $(SIGNING_FLAG) -b $(BINARIES_DIR) && \
		$(HOST_GOOGLE_SIGNING_CLEANUP))
endef

define HOST_BRUNOv2_SIGNING_SIGN
	(cp $(1) $(2) && \
	 $(HOST_GOOGLE_SIGNING_RETRIEVE_KEY) && \
		$(HOST_DIR)/usr/bin/python $(HOST_DIR)/usr/sbin/repack.py \
		-o $(HOST_DIR) $(SIGNING_FLAG) --bolt_sign -b $(BINARIES_DIR) -k $(2) && \
		$(HOST_GOOGLE_SIGNING_CLEANUP))
endef

define GOOGLE_CODE_SIGN_TOOL_EXECUTE
	(cd /google/src/files/head/depot/google3 && \
		blaze --batch run \
		--noshow_progress -- \
		//isp/fiber/drm:code_sign_tool \
		$(1) \
		$(2) \
		--image_type=$(3) \
		--keystore_config_id=$(KEYSTORE_CONFIG_ID) \
		--key_suffix=$(BR2_PACKAGE_GOOGLE_KEY_SUFFIX) \
		--outfile=$(2);)
endef
else
define HOST_GOOGLE_SIGNING_SIGN
  echo 'Unsigned build, skipping signer step...'
endef
define HOST_BRUNOv2_SIGNING_SIGN
  echo 'Unsigned build, skipping signer step...'
endef
define GOOGLE_CODE_SIGN_TOOL_EXECUTE
  echo 'Unsigned build, skipping signer step...'
endef
endif

# For optimus, developer and production images are always fake-signed, then a
# real signature is substituted for production builds.
ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
define HOST_GOOGLE_SIGNING_OPTIMUS_KERNEL_SIGN
	($(HOST_DIR)/usr/bin/python $(HOST_DIR)/usr/sbin/repack.py \
			-o $(HOST_DIR) -b $(BINARIES_DIR) -k $(1) && \
		$(call GOOGLE_CODE_SIGN_TOOL_EXECUTE,sign-image,$(BINARIES_DIR)/$(1),kernel,
		       $(2)))
endef
else
define HOST_GOOGLE_SIGNING_OPTIMUS_KERNEL_SIGN
	($(HOST_DIR)/usr/bin/python $(HOST_DIR)/usr/sbin/repack.py \
			-o $(HOST_DIR) -b $(BINARIES_DIR) -k $(1) && \
		echo "Development build, fake sign kernel...")
endef
endif

define HOST_GOOGLE_SIGNING_OPTIMUS_RECOVERY_SIGN
	($(HOST_DIR)/usr/bin/python $(HOST_DIR)/usr/sbin/repack.py \
			-o $(HOST_DIR) -b $(BINARIES_DIR) -k $(1) && \
		$(call GOOGLE_CODE_SIGN_TOOL_EXECUTE,sign-image,$(BINARIES_DIR)/$(1),recovery,
		       $(2)))
endef

define GOOGLE_SIGNING_EXTRACT_CMDS
	mkdir -p $(@D)
endef

define HOST_GOOGLE_SIGNING_EXTRACT_CMDS
	mkdir -p $(@D)
endef

sign_sn: sn.txt
	($(HOST_GOOGLE_SIGNING_RETRIEVE_KEY); \
		$(HOST_DIR)/usr/bin/python $(HOST_DIR)/usr/sbin/signserial.py \
		-o $(HOST_DIR) -b $(BINARIES_DIR) -f $<; \
		$(HOST_GOOGLE_SIGNING_CLEANUP))

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
