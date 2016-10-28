#############################################################
#
## trousers
#
##############################################################
TROUSERS_VERSION = 71d4fee1dc6db9bd22f6866571895b753f222ff5
TROUSERS_SITE = https://chromium.googlesource.com/chromiumos/third_party/trousers
TROUSERS_SITE_METHOD = git
TROUSERS_AUTORECONF = YES
TROUSERS_INSTALL_STAGING = YES
TROUSERS_INSTALL_TARGET = YES
TROUSERS_CONF_OPT = --disable-usercheck
TROUSERS_DEPENDENCIES = openssl host-pkg-config

HOST_TROUSERS_AUTORECONF = YES
HOST_TROUSERS_CONF_OPT = --disable-usercheck
HOST_TROUSERS_DEPENDENCIES = host-pkg-config

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
