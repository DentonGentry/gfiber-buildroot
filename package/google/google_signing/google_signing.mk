#############################################################
#
# google_signing (signing related code)
#
#############################################################
GOOGLE_SIGNING_SITE=repo://vendor/google/platform
GOOGLE_SIGNING_INSTALL_TARGET=YES

define GOOGLE_SIGNING_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)/bruno/signing
endef

define GOOGLE_SIGNING_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bruno/signing/readverity $(TARGET_DIR)/usr/sbin/
endef

$(eval $(call GENTARGETS))
