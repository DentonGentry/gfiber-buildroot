GOOGLE_OOKLA_SITE = repo://vendor/ookla
GOOGLE_OOKLA_DEPENDENCIES = poco

ifeq      ($(BR2_arm),y)
OOKLA_ARCH   := arm
else ifeq ($(BR2_mips),y)
OOKLA_ARCH   := mips
else ifeq ($(BR2_mipsel),y)
OOKLA_ARCH   := mips
endif

define GOOGLE_OOKLA_INSTALL_TARGET_CMDS
	cp -af $(@D)/$(OOKLA_ARCH)/OoklaClient $(TARGET_DIR)/usr/bin
	ln -sf /tmp/ookla/settings.xml $(TARGET_DIR)/usr/bin
endef

$(eval $(call GENTARGETS))
