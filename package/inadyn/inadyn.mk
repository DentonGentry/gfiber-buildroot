################################################################################
#
# inadyn
#
################################################################################

INADYN_VERSION = 1.99.12
INADYN_SITE = https://github.com/troglobit/inadyn/releases/download/$(INADYN_VERSION)
INADYN_SOURCE = inadyn-$(INADYN_VERSION).tar.xz
INADYN_LICENSE = GPLv2+
INADYN_LICENSE_FILES = COPYING LICENSE
INADYN_DEPENDENCIES = openssl
INADYN_CONF_OPT = --enable-openssl

define INADYN_INSTALL_CHROOT
	mkdir -p $(TARGET_DIR)/chroot/inadyn
	mkdir -p $(TARGET_DIR)/chroot/inadyn/etc
	mkdir -p $(TARGET_DIR)/chroot/inadyn/lib
	mkdir -p $(TARGET_DIR)/chroot/inadyn/usr/lib
	mkdir -p $(TARGET_DIR)/chroot/inadyn/usr/sbin
	mkdir -p $(TARGET_DIR)/chroot/inadyn/tmp
	ln -s tmp/dev $(TARGET_DIR)/chroot/inadyn/dev
endef

define INADYN_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/inadyn/S70inadyn \
		$(TARGET_DIR)/etc/init.d/S70inadyn
endef

INADYN_POST_INSTALL_TARGET_HOOKS += INADYN_INSTALL_CHROOT INADYN_INSTALL_INIT_SYSV

$(eval $(call AUTOTARGETS))
