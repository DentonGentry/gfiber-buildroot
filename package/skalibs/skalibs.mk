SKALIBS_VERSION = 2.3.10.0
SKALIBS_SOURCE = skalibs-$(SKALIBS_VERSION).tar.gz
SKALIBS_SITE = http://skarnet.org/software/skalibs
SKALIBS_INSTALL_STAGING = YES
SKALIBS_DEPENDENCIES =
HOST_SKALIBS_DEPENDENCIES =

SKALIBS_CONFIGURE_OPTS = \
	--prefix=/usr \
	--enable-force-devr \
	--enable-clock --enable-monotonic \
	--with-default-path=/sbin:/usr/sbin:/bin:/usr/bin \
	--disable-static --enable-shared --disable-allstatic

HOST_SKALIBS_CONFIGURE_OPTS = \
	--prefix=/usr \
	--enable-force-devr \
	--enable-clock --enable-monotonic \
	--with-default-path=/sbin:/usr/sbin:/bin:/usr/bin

define SKALIBS_CONFIGURE_CMDS
	cd $(@D) && \
	$(TARGET_CONFIGURE_OPTS) ./configure $(SKALIBS_CONFIGURE_OPTS)
endef

define SKALIBS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define SKALIBS_INSTALL_TARGET_CMDS
	# TODO(apenwarr): install only the libs we actually need.
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define SKALIBS_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef


define HOST_SKALIBS_CONFIGURE_CMDS
	cd $(@D) && \
	$(HOST_CONFIGURE_OPTS) ./configure $(HOST_SKALIBS_CONFIGURE_OPTS)
endef

define HOST_SKALIBS_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_SKALIBS_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR) install
endef


$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
