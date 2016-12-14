#############################################################
#
# libevent
#
#############################################################
LIBEVENT_VERSION = 2.1.7-rc
LIBEVENT_SOURCE = libevent-$(LIBEVENT_VERSION).tar.gz
LIBEVENT_SITE = https://github.com/libevent/libevent/archive/release-$(LIBEVENT_VERSION)
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
define HOST_LIBEVENT_DAMAGE_DEPRECATED
	for n in evdns.h evutil.h evrpc.h evhttp.h event.h; do \
		sed -i '1i#error "ev*.h deprecated, use event2/*.h or ev.h"' \
			$(HOST_DIR)/usr/include/$$n; \
	done
endef

# libevent installs a python script to target - get rid of it if we
# don't have python support enabled
ifneq ($(BR2_PACKAGE_PYTHON),y)
LIBEVENT_POST_INSTALL_TARGET_HOOKS += LIBEVENT_REMOVE_PYSCRIPT
endif

# libevent >= 2.1.7-rc requires manual autogen.sh invocation.
define LIBEVENT_AUTOGEN
	cd $(@D) && \
	$(TARGET_MAKE_ENV) ./autogen.sh
endef
LIBEVENT_PRE_CONFIGURE_HOOKS += LIBEVENT_AUTOGEN
HOST_LIBEVENT_PRE_CONFIGURE_HOOKS += LIBEVENT_AUTOGEN

# libev and libevent both install deprecated event.h.
# Damage deprecated files so we don't conflict.
LIBEVENT_POST_INSTALL_TARGET_HOOKS += LIBEVENT_DAMAGE_DEPRECATED
HOST_LIBEVENT_POST_INSTALL_HOOKS += HOST_LIBEVENT_DAMAGE_DEPRECATED

# Only build for SSL if it's enabled.
ifeq ($(BR2_PACKAGE_OPENSSL),y)
LIBEVENT_DEPENDENCIES += openssl
LIBEVENT_CONF_OPTS += --enable-openssl
# openssl needs zlib but configure forgets to link against it causing
# openssl detection to fail
ifeq ($(BR2_STATIC_LIBS),y)
LIBEVENT_CONF_ENV += OPENSSL_LIBADD='-lz'
endif
else
LIBEVENT_CONF_OPTS += --disable-openssl
endif

# We don't need samples, and we don't want the static libraries.
LIBEVENT_CONF_OPTS += --disable-samples --disable-static
HOST_LIBEVENT_CONF_OPTS += --disable-samples --disable-static

# Build with PIC only.
LIBEVENT_CONF_OPTS += --with-pic
HOST_LIBEVENT_CONF_OPTS += --with-pic

define LIBEVENT_REMOVE_PYSCRIPT
	rm $(TARGET_DIR)/usr/bin/event_rpcgen.py
endef

# libevent installs a python script to target - get rid of it if we
# don't have python support enabled
ifneq ($(BR2_PACKAGE_PYTHON),y)
LIBEVENT_POST_INSTALL_TARGET_HOOKS += LIBEVENT_REMOVE_PYSCRIPT
endif

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
