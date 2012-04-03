#############################################################
#
# procps
#
#############################################################

PROCPS_VERSION = 3.2.8
PROCPS_SITE = http://procps.sourceforge.net/

ifeq ($(BR2_PACKAGE_NCURSES),y)
PROCPS_DEPENDENCIES += ncurses
else
PROCPS_OPTS += NOCURSES=1
endif

define PROCPS_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(PROCPS_OPTS)
endef

define PROCPS_INSTALL_TARGET_CMDS
	mkdir -p $(addprefix $(TARGET_DIR)/,usr/bin bin sbin) \
		 $(addprefix $(TARGET_DIR)/usr/share/man/,man1 man5 man8)
	$(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) lib64=lib install=install \
		ldconfig=true install $(PROCPS_OPTS)
endef

$(eval $(call GENTARGETS,package,procps))
