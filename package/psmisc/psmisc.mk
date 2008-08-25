#############################################################
#
# psmisc
#
#############################################################
PSMISC_VERSION:=22.2
PSMISC_SOURCE:=psmisc-$(PSMISC_VERSION).tar.gz
PSMISC_SITE:=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/psmisc
PSMISC_AUTORECONF:=no
PSMISC_INSTALL_STAGING:=no
PSMISC_INSTALL_TARGET:=YES
PSMISC_INSTALL_TARGET_OPT:=DESTDIR=$(TARGET_DIR) install-strip
PSMISC_CONF_ENV:=ac_cv_func_malloc_0_nonnull=yes \
		 ac_cv_func_realloc_0_nonnull=yes
PSMISC_CONF_OPT:= $(DISABLE_NLS) $(DISABLE_IPV6)
PSMISC_DEPENDENCIES:=uclibc ncurses

$(eval $(call AUTOTARGETS,package,psmisc))
