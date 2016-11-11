#############################################################
#
# libev
#
#############################################################
LIBEV_VERSION = 4.22
LIBEV_SOURCE = libev-$(LIBEV_VERSION).tar.gz
LIBEV_SITE = http://dist.schmorp.de/libev/Attic/
LIBEV_INSTALL_STAGING = YES

define LIBEV_DAMAGE_DEPRECATED
	for n in event.h; do \
		sed -i '1i#error "ev*.h deprecated, use event2/*.h or ev.h"' \
	  		$(STAGING_DIR)/usr/include/$$n; \
	done
endef

# libev and libevent both install deprecated event.h.
# Damage deprecated files so we don't conflict.
LIBEV_POST_INSTALL_TARGET_HOOKS += LIBEV_DAMAGE_DEPRECATED

$(eval $(call AUTOTARGETS))
