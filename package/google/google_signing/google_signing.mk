#############################################################
#
# google_signing (signing related code)
#
#############################################################
GOOGLE_SIGNING_SITE=repo://vendor/google/platform
GOOGLE_SIGNING_DEPENDENCIES=host-gtest host-py-openssl \
			    host-google_keystore_client
GOOGLE_SIGNING_INSTALL_TARGET=YES
GOOGLE_SIGNING_TEST=YES

ifeq ($(BR2_PACKAGE_BRUNO_PROD),y)
GOOGLE_SIGNING_DEPENDENCIES += bcm_signing host-bcm_signing
endif

HOST_GOOGLE_SIGNING_TEST=YES
SIGNING_DIR=$(BINARIES_DIR)/signing

define GOOGLE_SIGNING_BUILD_CMDS
	HOST_DIR=$(HOST_DIR) CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C \
		 $(@D)/signing
endef

SIGNING_FLAG=""
ifeq ($(BR2_PACKAGE_BRUNO_PROD),y)
define HOST_GOOGLE_SIGNING_RETRIEVE_KEY
	(mkdir -m 700 -p $(SIGNING_DIR); \
	$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,signing_private_key,$(SIGNING_DIR)/gfiber_private.pem); \
	$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,signing_public_key_signature,$(SIGNING_DIR)/gfiber_key_sig.bin))
endef
SIGNING_FLAG="-s"
else
define HOST_GOOGLE_SIGNING_RETRIEVE_KEY
	echo "Skip retrieving signing key..."
endef
endif

define HOST_GOOGLE_SIGNING_SIGN
	($(HOST_GOOGLE_SIGNING_RETRIEVE_KEY); \
	$(HOST_DIR)/usr/sbin/repack.py -o $(HOST_DIR) $(SIGNING_FLAG) \
		-b $(BINARIES_DIR); \
	if [ -d "$(SIGNING_DIR)" ]; then \
		shred -f -u -z -n 5 $(SIGNING_DIR)/*; \
		rm -rf $(SIGNING_DIR); \
	fi)
endef

define GOOGLE_SIGNING_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/signing/readverity \
		$(TARGET_DIR)/usr/sbin/readverity
endef

define GOOGLE_SIGNING_TEST_CMDS
	(cd $(@D)/signing; ./readverity_test)
endef

define HOST_GOOGLE_SIGNING_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/usr/sbin/
	$(INSTALL) -D -m 0755 $(@D)/signing/repack.py \
		$(HOST_DIR)/usr/sbin/repack.py
endef

define HOST_GOOGLE_SIGNING_TEST_CMDS
	(cd $(@D)/signing; $(HOST_DIR)/usr/bin/python repacktest.py)
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
