S6_VERSION = 2.3.0.0
S6_SOURCE = s6-$(S6_VERSION).tar.gz
S6_SITE = http://skarnet.org/software/s6
S6_INSTALL_STAGING = YES
S6_DEPENDENCIES = skalibs execline
HOST_S6_DEPENDENCIES = host-skalibs host-execline

S6_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(STAGING_DIR)/usr/include \
	--with-dynlib=$(STAGING_DIR)/usr/lib \
	--disable-static --enable-shared --disable-allstatic

HOST_S6_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(HOST_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(HOST_DIR)/usr/include \
	--with-dynlib=$(HOST_DIR)/usr/lib \
	--with-lib=$(HOST_DIR)/usr/lib/execline \
	--with-lib=$(HOST_DIR)/usr/lib/skalibs

define S6_CONFIGURE_CMDS
	cd $(@D) && \
	$(TARGET_CONFIGURE_OPTS) ./configure $(S6_CONFIGURE_OPTS)
endef

define S6_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define S6_INSTALL_TARGET_CMDS
	# TODO(apenwarr): install only the binaries we actually need.
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
	ln -sf /tmp/service $(TARGET_DIR)/service
endef

define S6_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef


define HOST_S6_CONFIGURE_CMDS
	cd $(@D) && \
	$(HOST_CONFIGURE_OPTS) ./configure $(HOST_S6_CONFIGURE_OPTS)
endef

define HOST_S6_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_S6_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR) install
endef


$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
