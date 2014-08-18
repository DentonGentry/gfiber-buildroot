#############################################################
#
# openssh
#
#############################################################

OPENSSH_VERSION = 5.9p1
OPENSSH_SITE = http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable
OPENSSH_CONF_ENV = LD="$(TARGET_CC)" LDFLAGS="$(TARGET_CFLAGS)"
OPENSSH_CONF_OPT = --libexecdir=/usr/lib --disable-lastlog --disable-utmp \
		--disable-utmpx --disable-wtmp --disable-wtmpx --disable-strip

OPENSSH_DEPENDENCIES = zlib openssl

define OPENSSH_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 $(@D)/sftp-server $(TARGET_DIR)/usr/libexec/sftp-server
endef

# @note We are replacing the default install steps
# with an explicit "install only sftp-server" command.
# The rationale is that we need sftp-server in order
# to make sshfs work, but we do not want to move from
# dropbear to openssh (yet). Once we move, we should
# remove the explicit install command, so that the
# whole package gets installed.

define OPENSSH_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/libexec/sftp-server
endef


OPENSSH_POST_INSTALL_TARGET_HOOKS += OPENSSH_INSTALL_INITSCRIPT

$(eval $(call AUTOTARGETS))
