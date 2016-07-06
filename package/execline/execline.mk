EXECLINE_VERSION = 2.1.5.0
EXECLINE_SOURCE = execline-$(EXECLINE_VERSION).tar.gz
EXECLINE_SITE = http://skarnet.org/software/execline
EXECLINE_INSTALL_STAGING = YES
EXECLINE_DEPENDENCIES = skalibs
HOST_EXECLINE_DEPENDENCIES = host-skalibs

EXECLINE_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(STAGING_DIR)/usr/include \
	--with-dynlib=$(STAGING_DIR)/usr/lib \
	--disable-static --enable-shared --disable-allstatic

HOST_EXECLINE_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(HOST_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(HOST_DIR)/usr/include \
	--with-dynlib=$(HOST_DIR)/usr/lib \
	--with-lib=$(HOST_DIR)/usr/lib/skalibs

define EXECLINE_CONFIGURE_CMDS
	cd $(@D) && \
	$(TARGET_CONFIGURE_OPTS) ./configure $(EXECLINE_CONFIGURE_OPTS)
endef

define EXECLINE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define EXECLINE_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define EXECLINE_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef


define HOST_EXECLINE_CONFIGURE_CMDS
	cd $(@D) && \
	$(HOST_CONFIGURE_OPTS) ./configure $(HOST_EXECLINE_CONFIGURE_OPTS)
endef

define HOST_EXECLINE_BUILD_CMDS
	# TODO(apenwarr): install only the libs/binaries we actually need.
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_EXECLINE_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR) install
endef


$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
