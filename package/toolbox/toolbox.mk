TOOLBOX_SITE=repo://toolbox-for-linux

# TODO
# replacements needed for:
# getty, udhcpd, ntpd, mount (w/ volume support), fdisk

define TOOLBOX_BUILD_CMDS
	$(MAKE) -C $(@D) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" all
endef

define TOOLBOX_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D) CC="$(TARGET_CC)" TARGET_OUT="$(TARGET_DIR)/bin" install
endef

$(eval $(call GENTARGETS))
