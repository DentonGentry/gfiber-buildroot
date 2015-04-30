#############################################################
#
# sudo
#
#############################################################

SUDO_VERSION = 1.7.8p1
SUDO_SITE    = http://www.sudo.ws/sudo/dist

SUDO_CONF_OPT = \
		--without-lecture \
		--without-sendmail \
		--without-umask \
		--with-logging=syslog \
		--without-interfaces \
		--without-pam

define SUDO_INSTALL_TARGET_CMDS
	install -m 4555 -D $(@D)/sudo $(TARGET_DIR)/usr/bin/sudo
	install -m 0555 -D $(@D)/visudo $(TARGET_DIR)/usr/sbin/visudo
	install -m 0440 -D $(@D)/sudoers $(TARGET_DIR)/etc/sudoers
endef

ifeq ($(BR2_PACKAGE_SUDO_ROOT_ONLY),y)
SUDO_PERMS = /usr/bin/sudo f 4500 0 0 - - - - -
endif

define SUDO_PERMISSIONS
	/etc/sudoers f 0440 0 0 - - - - -
	$(SUDO_PERMS)
endef

$(eval $(call AUTOTARGETS))
