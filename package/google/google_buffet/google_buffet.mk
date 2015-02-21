#############################################################
#
# google_buffet
#
#############################################################

CHROMEOS_VERSION = R42-6798
GOOGLE_BUFFET_SITE = repo://vendor/google/tarballs

define GOOGLE_BUFFET_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/chroot && \
	tar -zxvf $(@D)/google_buffet-$(CHROMEOS_VERSION).tar.gz -C $(TARGET_DIR)/chroot
	mkdir -p $(TARGET_DIR)/chroot/chromeos/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/base_state.schema.json $(TARGET_DIR)/chroot/chromeos/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/base_state.defaults.json $(TARGET_DIR)/chroot/chromeos/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/buffet.conf $(TARGET_DIR)/chroot/chromeos/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/gcd.json $(TARGET_DIR)/chroot/chromeos/etc/buffet
	mkdir -p $(TARGET_DIR)/etc/init.d && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/S99buffet $(TARGET_DIR)/etc/init.d/S99buffet
	mkdir -p $(TARGET_DIR)/etc/dbus-1/system.d && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/org.chromium.Buffet.conf $(TARGET_DIR)/etc/dbus-1/system.d/org.chromium.Buffet.conf
	# Create chroot binding point for dbus.
	mkdir -p $(TARGET_DIR)/chroot/chromeos/var/run/dbus
endef

define GOOGLE_BUFFET_CLEAN_CMDS
	rm -rf $(TARGET_DIR)/etc/dbus-1/system.d/org.chromium.Buffet.conf
	rm -rf $(TARGET_DIR)/etc/init.d/S99buffet
	rm -rf $(TARGET_DIR)/chroot/chromeos
endef

$(eval $(call GENTARGETS))
