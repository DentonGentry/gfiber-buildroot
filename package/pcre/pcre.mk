#############################################################
#
# PCRE
#
#############################################################

PCRE_VERSION = 8.38
PCRE_SITE = ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre
PCRE_INSTALL_STAGING = YES
PCRE_CONFIG_SCRIPTS = pcre-config

# PCRE comes configured with a version of libtool that's too new for our
# Buildroot to patch. autoreconf it so we can use our libtool instead.
PCRE_AUTORECONF = YES

ifneq ($(BR2_INSTALL_LIBSTDCPP),y)
# pcre will use the host g++ if a cross version isn't available
PCRE_CONF_OPT = --disable-cpp
endif

$(eval $(call AUTOTARGETS))
