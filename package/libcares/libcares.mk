#############################################################
#
# libcares
#
#############################################################

LIBCARES_VERSION = 1.10.0
LIBCARES_SOURCE = c-ares-$(LIBCARES_VERSION).tar.gz
LIBCARES_SITE = http://c-ares.haxx.se/download/
LIBCARES_INSTALL_STAGING = YES
LIBCARES_CONF_OPT = --enable-largefile

# We need a custom configure since libcares doesn't like
# defines in CFLAGS
define LIBCARES_CONFIGURE_CMDS
  (cd $(@D); rm -rf config.cache; \
    $(TARGET_CONFIGURE_ARGS) \
    $(TARGET_CONFIGURE_OPTS) \
    CPPFLAGS="$(filter -D%,$(TARGET_CFLAGS))" \
    CFLAGS="$(filter-out -D%,$(TARGET_CFLAGS))" \
    $(LOGLINEAR) ./configure \
    --target=$(GNU_TARGET_NAME) \
    --host=$(GNU_TARGET_NAME) \
    --build=$(GNU_HOST_NAME) \
    --prefix=/usr \
  )
endef

define HOST_LIBCARES_CONFIGURE_CMDS
  (cd $(@D); rm -rf config.cache; \
    $(HOST_CONFIGURE_ARGS) \
    $(HOST_CONFIGURE_OPTS) \
    CPPFLAGS="$(filter -D%,$(HOST_CFLAGS))" \
    CFLAGS_TMP="$(filter-out -D%,$(HOST_CFLAGS))" \
    CFLAGS="$(filter-out -I%,$(CFLAGS_TMP))" \
    $(LOGLINEAR) ./configure --prefix=/usr \
  )
endef

define LIBCARES_BUILD_CMDS
  $(MAKE1) -C $(@D)
endef

define LIBCARES_INSTALL_STAGING_CMDS
  $(MAKE1) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

define LIBCARES_INSTALL_TARGET_CMDS
  $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define HOST_LIBCARES_INSTALL_CMDS
  $(MAKE1) -C $(@D) DESTDIR=$(HOST_DIR) install
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))

