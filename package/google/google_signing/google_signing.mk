#############################################################
#
# google_signing (signing related code)
#
#############################################################
GOOGLE_SIGNING_SITE=repo://vendor/google/platform
GOOGLE_SIGNING_DEPENDENCIES=host-gtest
GOOGLE_SIGNING_INSTALL_TARGET=YES
GOOGLE_SIGNING_TEST=YES
HOST_GOOGLE_SIGNING_TEST=YES

define GOOGLE_SIGNING_BUILD_CMDS
	HOST_DIR=$(HOST_DIR) CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C \
		    $(@D)/signing
endef

define GOOGLE_SIGNING_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin/
	$(INSTALL) -D -m 0755 $(@D)/signing/readverity $(TARGET_DIR)/usr/sbin/
endef

define GOOGLE_SIGNING_TEST_CMDS
	(cd $(@D)/signing; ./readverity_test)
endef

define HOST_GOOGLE_SIGNING_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/usr/sbin/
	$(INSTALL) -D -m 0755 $(@D)/signing/repack.py $(HOST_DIR)/usr/sbin/
endef

# TODO(kedong) add openssl for host-python and replace ubuntu python with
# host-python
define HOST_GOOGLE_SIGNING_TEST_CMDS
	(cd $(@D)/signing; python repacktest.py)
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
