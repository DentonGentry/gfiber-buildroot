QUALCOMM_SWITCH_SITE=repo://vendor/qualcomm/switch
QUALCOMM_SWITCH_INSTALL_STAGING = YES

QUALCOMM_SWITCH_MAKE = \
	OS="linux" \
	OS_VER=3_2 \
	GCC_VER=4 \
	CPU="$(BR2_ARCH)" \
	CHIP_TYPE=ISISC \
	KERNEL_MODE=FALSE \
	TOOL_PATH="$(TARGET_CROSS)" \
	SYS_PATH="$(LINUX_DIR)" \
	CC="$(TARGET_CC)" \
	AR="$(TARGET_AR)" \
	LD="$(TARGET_LD)" \
	STRIP="$(TARGET_STRIP)" \
	CP="cp" \
	MKDIR="mkdir" \
	RM="rm" \
	PERL="perl"

define QUALCOMM_SWITCH_BUILD_CMDS
	$(MAKE) $(QUALCOMM_SWITCH_MAKE) -C $(@D) config2h
	$(MAKE) $(QUALCOMM_SWITCH_MAKE) -C $(@D) shell
endef

define QUALCOMM_SWITCH_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/build/bin/ssdk_us_um.a $(STAGING_DIR)/usr/lib/ssdk_us_um.a
endef

define QUALCOMM_SWITCH_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0555 $(@D)/build/bin/ssdk_sh $(TARGET_DIR)/usr/bin/ssdk_sh
endef

$(eval $(call GENTARGETS))
