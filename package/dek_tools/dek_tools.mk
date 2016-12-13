DEK_TOOLS_SITE=repo://vendor/marvell/dek-tools

define DEK_TOOLS_CLEAN_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) TARGET=buildroot CC=$(TARGET_CROSS)gcc \
	AR=$(TARGET_CROSS)ar -C $(@D) clean
endef

define DEK_TOOLS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) TARGET=buildroot CC=$(TARGET_CROSS)gcc \
	AR=$(TARGET_CROSS)ar -C $(@D)
endef

define DEK_TOOLS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/apps/* $(TARGET_DIR)/usr/bin/
endef

$(eval $(call GENTARGETS))
