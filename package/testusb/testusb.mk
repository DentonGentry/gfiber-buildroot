#############################################################
#
# testusb
#
#############################################################

# source included in buildroot
TESTUSB_SOURCE =

define TESTUSB_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) -Wall -g -lpthread $(TARGET_LDFLAGS) \
		package/testusb/testusb.c -o $(@D)/testusb
endef

define TESTUSB_INSTALL_TARGET_CMDS
	install -D -m 755 $(@D)/testusb $(TARGET_DIR)/usr/bin/testusb
endef

define TESTUSB_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/testusb
endef

$(eval $(call GENTARGETS))
