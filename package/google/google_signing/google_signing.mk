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
	HOSTDIR=$(HOST_DIR) CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C \
		 $(@D)/signing
endef

SIGNING_FLAG=""
ifeq ($(BR2_PACKAGE_BRUNO_PROD),y)
define HOST_GOOGLE_SIGNING_RETRIEVE_KEY
	(mkdir -m 700 -p $(SIGNING_DIR); \
	$(call GOOGLE_KEYSTORE_CLIENT_EXECUTE,signing_private_key,$(SIGNING_DIR)/gfiber_private.pem))
endef
SIGNING_FLAG="-s"
GOOGLE_KEYSTORE_CLIENT_NEEDS_KEYS += \
	signing_private_key \
	signing_public_key_signature
else
define HOST_GOOGLE_SIGNING_RETRIEVE_KEY
	echo "Skip retrieving signing key..."
endef
endif

define HOST_GOOGLE_SIGNING_CLEANUP
	if [ -d "$(SIGNING_DIR)" ]; then \
		shred -f -u -z -n 5 $(SIGNING_DIR)/*; \
		rm -rf $(SIGNING_DIR); \
	fi
endef

define HOST_GOOGLE_SIGNING_SIGN
	($(HOST_GOOGLE_SIGNING_RETRIEVE_KEY); \
		$(HOST_DIR)/usr/sbin/repack.py -o $(HOST_DIR) $(SIGNING_FLAG) \
		-b $(BINARIES_DIR); $(HOST_GOOGLE_SIGNING_CLEANUP))
endef

define GOOGLE_SIGNING_INSTALL_TARGET_CMDS
	$(MAKE) HOSTDIR=$(HOST_DIR) TARGET_DIR=$(TARGET_DIR) \
		INSTALL=$(INSTALL) -C $(@D)/signing install
endef

define GOOGLE_SIGNING_TEST_CMDS
	$(MAKE) HOSTDIR=$(HOST_DIR) -C $(@D)/signing test
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
