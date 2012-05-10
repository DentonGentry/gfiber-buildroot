#############################################################
#
# ccache
#
#############################################################

CCACHE_VERSION = 3.1.7
CCACHE_SITE    = http://samba.org/ftp/ccache
CCACHE_SOURCE  = ccache-$(CCACHE_VERSION).tar.bz2

# When ccache is being built for the host, ccache is not yet
# available, so we have to use the special C compiler without the
# cache.
HOST_CCACHE_CONF_ENV = \
	CC="$(HOSTCC_NOCCACHE)"

# We directly hardcode the cache location into the binary, as it is
# much easier to handle than passing an environment variable.
define HOST_CCACHE_FIX_CCACHE_DIR
	sed -i 's,getenv("CCACHE_DIR"),"$(CCACHE_CACHE_DIR)",' $(@D)/ccache.c
endef

HOST_CCACHE_POST_CONFIGURE_HOOKS += \
	HOST_CCACHE_FIX_CCACHE_DIR

# optimizations for ccache
export CCACHE_COMPILERCHECK=none
export CCACHE_BASEDIR=$(BUILD_DIR)
export CCACHE_SLOPPINESS=time_macros

HOST_CCACHE_POST_INSTALL_HOOKS += HOST_CCACHE_LARGE_LIMITS

define HOST_CCACHE_LARGE_LIMITS
	$(CCACHE) -M=20G -F=0
endef

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))

ifeq ($(BR2_CCACHE),y)
ccache-stats: host-ccache
	$(Q)$(CCACHE) -s
endif

