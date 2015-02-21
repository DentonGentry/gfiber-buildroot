TLSDATE_VERSION = 0.0.7
TLSDATE_SITE = http://ftp.de.debian.org/debian/pool/main/t/tlsdate
TLSDATE_SOURCE = tlsdate_${TLSDATE_VERSION}.orig.tar.gz
TLSDATE_DEPENDENCIES = host-pkg-config openssl

TLSDATE_PRE_CONFIGURE_HOOKS += TLSDATE_AUTOGEN
TLSDATE_CONF_OPT = --disable-hardened-checks

define TLSDATE_INSTALL_DAEMON_INITSCRIPT
	$(INSTALL) -m 0755 package/tlsdate/S75tlsdate $(TARGET_DIR)/etc/init.d/
endef

TLSDATE_POST_INSTALL_TARGET_HOOKS += TLSDATE_INSTALL_DAEMON_INITSCRIPT

define TLSDATE_AUTOGEN
	cd $(@D) && \
	$(TARGET_MAKE_ENV) ./autogen.sh
endef

$(eval $(call AUTOTARGETS))
