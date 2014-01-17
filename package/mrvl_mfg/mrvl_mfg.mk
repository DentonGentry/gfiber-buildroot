MRVL_MFG_SITE=repo://vendor/marvell/manufacturing
MRVL_MFG_INSTALL_TARGET=YES
MRVL_MFG_DEPENDENCIES=linux bluez_utils

MRVL_MFG_MAKE_ENV = \
	$(TARGET_MAKE_ENV) \
	$(LINUX_MAKE_FLAGS) \
	KLIB_BUILD=$(LINUX_DIR) \
	KLIB=$(TARGET_DIR)

define MRVL_MFG_BUILD_CMDS
	$(MRVL_MFG_MAKE_ENV) $(MAKE) -C $(LINUX_DIR) M=$(@D)/ZOMG/wlan_src
	CC="$(TARGET_CC)" CFLAGS="-I$(STAGING_DIR)/usr/include" \
	   $(MAKE) -C $(MRVL_MFG_DIR)/userspace/bridge
endef

define MRVL_MFG_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/modules/mfg
	install -D -m 0644 $(@D)/ZOMG/wlan_src/*.ko $(TARGET_DIR)/lib/modules/mfg
	$(STRIPCMD) $(TARGET_DIR)/lib/modules/mfg/*.ko
	install -D -m 0755 $(@D)/userspace/bridge/mfgbridge $(TARGET_DIR)/usr/sbin
	$(STRIPCMD) $(TARGET_DIR)/usr/sbin/mfgbridge
endef

$(eval $(call GENTARGETS))
