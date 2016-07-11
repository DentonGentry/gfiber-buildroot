S6_RC_VERSION = 0.0.3.0
S6_RC_SOURCE = s6-rc-$(S6_RC_VERSION).tar.gz
S6_RC_SITE = http://skarnet.org/software/s6-rc
S6_RC_INSTALL_STAGING = YES
S6_RC_DEPENDENCIES = skalibs execline s6
HOST_S6_RC_DEPENDENCIES = host-skalibs host-execline host-s6

# We need the host-compiled version of s6-rc in order to compile the
# service database during install.
S6_RC_DEPENDENCIES += host-s6 host-s6-rc

S6_RC_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(STAGING_DIR)/usr/include \
	--with-dynlib=$(STAGING_DIR)/usr/lib \
	--disable-static --enable-shared --disable-allstatic

HOST_S6_RC_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(HOST_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(HOST_DIR)/usr/include \
	--with-dynlib=$(HOST_DIR)/usr/lib \
	--with-lib=$(HOST_DIR)/usr/lib/s6 \
	--with-lib=$(HOST_DIR)/usr/lib/execline \
	--with-lib=$(HOST_DIR)/usr/lib/skalibs

define S6_RC_CONFIGURE_CMDS
	cd $(@D) && \
	$(TARGET_CONFIGURE_OPTS) ./configure $(S6_RC_CONFIGURE_OPTS)
endef

define S6_RC_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define S6_RC_INSTALL_TARGET_CMDS
	# TODO(apenwarr): install only the binaries we actually need.
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
	ln -sf /tmp/run $(TARGET_DIR)/run
endef

define S6_RC_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef


define HOST_S6_RC_CONFIGURE_CMDS
	cd $(@D) && \
	$(HOST_CONFIGURE_OPTS) ./configure $(HOST_S6_RC_CONFIGURE_OPTS)
endef

define HOST_S6_RC_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_S6_RC_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR) install
endef


$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
