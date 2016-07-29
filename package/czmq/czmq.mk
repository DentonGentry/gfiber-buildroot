################################################################################
#
# czmq
#
################################################################################

CZMQ_VERSION = 5205ec201e97c3a652c17eb86b18b70350b54512
CZMQ_SITE = git://github.com/zeromq/czmq.git

# Autoreconf required as we use the git tree
CZMQ_AUTORECONF = YES
HOST_CZMQ_AUTORECONF = YES
CZMQ_INSTALL_STAGING = YES
CZMQ_DEPENDENCIES = zeromq host-pkgconf
HOST_CZMQ_DEPENDENCIES = host-zeromq host-pkgconf
CZMQ_LICENSE = MPLv2.0
CZMQ_LICENSE_FILES = LICENSE

# asciidoc is a python script that imports unicodedata, which is not in
# host-python, so disable asciidoc entirely.
CZMQ_CONF_ENV = ac_cv_prog_czmq_have_asciidoc=no
HOST_CZMQ_CONF_ENV = ac_cv_prog_czmq_have_asciidoc=no
HOST_CZMQ_CONF_OPT = --enable-drafts

define CZMQ_CREATE_CONFIG_DIR
	mkdir -p $(@D)/config
endef

CZMQ_POST_PATCH_HOOKS += CZMQ_CREATE_CONFIG_DIR
HOST_CZMQ_POST_PATCH_HOOKS += CZMQ_CREATE_CONFIG_DIR

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
