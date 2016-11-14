#############################################################
#
# libevent
#
#############################################################
LIBEVENT_VERSION = 2.1.5
LIBEVENT_SOURCE = libevent-$(LIBEVENT_VERSION)-beta.tar.gz
LIBEVENT_SITE = https://github.com/libevent/libevent/releases/download/release-$(LIBEVENT_VERSION)-beta

LIBEVENT_AUTORECONF = NO
LIBEVENT_INSTALL_STAGING = YES
LIBEVENT_INSTALL_TARGET = YES

define LIBEVENT_REMOVE_PYSCRIPT
	rm $(TARGET_DIR)/usr/bin/event_rpcgen.py
endef

define LIBEVENT_DAMAGE_DEPRECATED
	for n in evdns.h evutil.h evrpc.h evhttp.h event.h; do \
		sed -i '1i#error "ev*.h deprecated, use event2/*.h or ev.h"' \
			$(STAGING_DIR)/usr/include/$$n; \
	done
endef

# libevent installs a python script to target - get rid of it if we
# don't have python support enabled
ifneq ($(BR2_PACKAGE_PYTHON),y)
LIBEVENT_POST_INSTALL_TARGET_HOOKS += LIBEVENT_REMOVE_PYSCRIPT
endif

# libev and libevent both install deprecated event.h.
# Damage deprecated files so we don't conflict.
LIBEVENT_POST_INSTALL_TARGET_HOOKS += LIBEVENT_DAMAGE_DEPRECATED

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
