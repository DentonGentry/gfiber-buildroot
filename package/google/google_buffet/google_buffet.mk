#############################################################
#
# google_buffet
#
#############################################################

CHROMEOS_VERSION = R42-6798
GOOGLE_BUFFET_SITE = repo://vendor/google/tarballs

define GOOGLE_BUFFET_INSTALL_TARGET_CMDS
	# Untar and place the chromeos rootdir under /chroot
	mkdir -p $(TARGET_DIR)/chroot && \
	tar -zxvf $(@D)/google_buffet-$(CHROMEOS_VERSION).tar.gz -C $(TARGET_DIR)/chroot
	# Copy necessary configs to /etc/buffet
	mkdir -p $(TARGET_DIR)/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/base_state.schema.json $(TARGET_DIR)/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/base_state.defaults.json $(TARGET_DIR)/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/buffet.conf $(TARGET_DIR)/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/gcd.json $(TARGET_DIR)/etc/buffet
	# Install demo test.json command definition to /etc/buffet/commands
	mkdir -p $(TARGET_DIR)/etc/buffet/commands && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/test.json $(TARGET_DIR)/etc/buffet/commands
	# Install /etc/init.d/S99buffet script
	mkdir -p $(TARGET_DIR)/etc/init.d && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/S99buffet $(TARGET_DIR)/etc/init.d/S99buffet
	# Install customized dbus config to run in chroot.
	mkdir -p $(TARGET_DIR)/etc/dbus-1/system.d && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/org.chromium.Buffet.conf $(TARGET_DIR)/etc/dbus-1/system.d/org.chromium.Buffet.conf
	# Create chroot binding point for dbus.
	mkdir -p $(TARGET_DIR)/chroot/chromeos/var/lib
	mkdir -p $(TARGET_DIR)/chroot/chromeos/var/run
	mkdir -p $(TARGET_DIR)/chroot/chromeos/etc
	mkdir -p $(TARGET_DIR)/chroot/chromeos/tmp
	# libcurl.so.4 in ChromeOS expected Equifax cert with hash name 578d5c04.0
	cp -p $(TARGET_DIR)/etc/ssl/certs/ca-certificates.crt $(TARGET_DIR)/etc/ssl/certs/578d5c04.0
endef

define GOOGLE_BUFFET_CLEAN_CMDS
	rm -rf $(TARGET_DIR)/etc/dbus-1/system.d/org.chromium.Buffet.conf
	rm -rf $(TARGET_DIR)/etc/init.d/S99buffet
	rm -rf $(TARGET_DIR)/chroot/chromeos
endef

$(eval $(call GENTARGETS))
