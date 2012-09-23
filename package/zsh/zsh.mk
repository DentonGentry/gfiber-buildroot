#
# ZSH
#

ZSH_VERSION=4.3.17
ZSH_SOURCE=zsh-$(ZSH_VERSION).tar.bz2
ZSH_SITE=http://sourceforge.net/projects/zsh/files/zsh-dev/$(ZSH_VERSION)
# Just intall the binary, regardless of other stuff generated for /usr/share and /usr/man.
ifeq ($(BR2_PACKAGE_ZSH_BINARIES_ONLY),y)
ZSH_INSTALL_TARGET_OPT = DESTDIR=$(TARGET_DIR) install.bin
endif
ifeq ($(BR2_PACKAGE_NCURSES),y)
ZSH_DEPENDENCIES += ncurses
endif


$(eval $(call AUTOTARGETS))
