#############################################################
#
## trousers
#
##############################################################
TROUSERS_VERSION = 71d4fee1dc6db9bd22f6866571895b753f222ff5
TROUSERS_SITE = https://chromium.googlesource.com/chromiumos/third_party/trousers
TROUSERS_SITE_METHOD = git
TROUSERS_AUTORECONF = YES
TROUSERS_INSTALL_STAGING = YES
TROUSERS_INSTALL_TARGET = YES
TROUSERS_INSTALL_STAGING_OPT = DESTDIR=$${STAGING_DIR} all
TROUSERS_INSTALL_TARGET_OPT = DESTDIR=$${TARGET_DIR} all
TROUSERS_UNINSTALL_STAGING_OPT = DESTDIR=$${STAGING_DIR} clean
TROUSERS_UNINSTALL_TARGET_OPT = DESTDIR=$${TARGET_DIR} clean
TROUSERS_DEPENDENCIES = openssl host-pkg-config

define TROUSERS_INSTALL_STAGING_CMDS
	$(INSTALL) -d $(STAGING_DIR)/usr/include/tss/
	$(INSTALL) -m 0644 -t $(STAGING_DIR)/usr/include/tss/ $(@D)/src/include/tss/*
	$(INSTALL) -d $(STAGING_DIR)/usr/include/trousers/
	$(INSTALL) -m 0644 -t $(STAGING_DIR)/usr/include/trousers/ $(@D)/src/include/trousers/*
	$(INSTALL) -D -m 0755 $(@D)/src/tspi/.libs/libtspi.so.1.2.0 \
		$(STAGING_DIR)/usr/lib/
	ln -fs libtspi.so.1.2.0 \
		$(STAGING_DIR)/usr/lib/libtspi.so.1
	ln -fs libtspi.so.1 \
		$(STAGING_DIR)/usr/lib/libtspi.so
endef

define TROUSERS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/src/tcsd/tcsd \
		$(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/dist/tcsd.conf \
		$(TARGET_DIR)/etc/
	$(INSTALL) -D -m 0755 $(@D)/src/tspi/.libs/libtspi.so.1.2.0 \
		$(TARGET_DIR)/usr/lib/
	ln -fs libtspi.so.1.2.0 \
		$(TARGET_DIR)/usr/lib/libtspi.so.1
	$(INSTALL) -D -m 0755 $(@D)/src/tspi/.libs/libtspi.a \
		$(TARGET_DIR)/usr/lib/
endef

define TROUSERS_UNINSTALL_STAGING_CMDS
	$(RM) -r $(STAGING_DIR)/usr/include/trousers/
	$(RM) -r $(STAGING_DIR)/usr/include/tss/
	$(RM) $(STAGING_DIR)/usr/lib/libtspi.so.1.2.0
	$(RM) $(STAGING_DIR)/usr/lib/libtspi.so.1
	$(RM) $(STAGING_DIR)/usr/lib/libtspi.so
endef

define TROUSERS_UNINSTALL_TARGET_CMDS
	$(RM) $(TARGET_DIR)/usr/bin/tcsd
	$(RM) $(TARGET_DIR)/etc/tcsd.conf
	$(RM) $(TARGET_DIR)/usr/lib/libtspi.so.1.2.0
	$(RM) $(TARGET_DIR)/usr/lib/libtspi.so.1
endef

$(eval $(call AUTOTARGETS))
