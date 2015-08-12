#############################################################
#
# google_buffet
#
#############################################################

BUFFET_CHROMEOS_VERSION = R44-7077
GOOGLE_BUFFET_SITE = repo://vendor/google/tarballs

ifeq ($(BR2_PACKAGE_GOOGLE_BUFFET_DEMOS),y)
define HOST_GOOGLE_BUFFET_DEMOS
		mkdir -p $(TARGET_DIR)/etc/buffet && \
		$(INSTALL) -m 0755 -D package/google/google_buffet/buffet.conf $(TARGET_DIR)/etc/buffet; \
		mkdir -p $(TARGET_DIR)/etc/buffet/commands && \
		$(INSTALL) -m 0755 -D package/google/google_buffet/test.json $(TARGET_DIR)/etc/buffet/commands
endef
else
define HOST_GOOGLE_BUFFET_DEMOS
	echo "Skip Buffet demos..."
endef
endif

define GOOGLE_BUFFET_INSTALL_TARGET_CMDS
	# Untar and place the chromeos rootdir under /chroot
	mkdir -p $(TARGET_DIR)/chroot && \
	tar -zxvf $(@D)/google_buffet-$(BUFFET_CHROMEOS_VERSION).tar.gz -C $(TARGET_DIR)/chroot
	# Copy global configs to /etc/buffet
	mkdir -p $(TARGET_DIR)/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/base_state.schema.json $(TARGET_DIR)/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/base_state.defaults.json $(TARGET_DIR)/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/gcd.json $(TARGET_DIR)/etc/buffet
	# Install Buffet demos
	$(HOST_GOOGLE_BUFFET_DEMOS)
	# Install /etc/init.d file
	mkdir -p $(TARGET_DIR)/etc/init.d && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/S86buffet $(TARGET_DIR)/etc/init.d/
	# Install customized dbus config to run in chroot.
	mkdir -p $(TARGET_DIR)/etc/dbus-1/system.d && \
	$(INSTALL) -m 0755 -D package/google/google_buffet/org.chromium.Buffet.conf $(TARGET_DIR)/etc/dbus-1/system.d/org.chromium.Buffet.conf
	# Create chroot binding point for dbus.
	mkdir -p $(TARGET_DIR)/chroot/chromeos/var/lib/buffet
	mkdir -p $(TARGET_DIR)/chroot/chromeos/var/run
	mkdir -p $(TARGET_DIR)/chroot/chromeos/etc
	mkdir -p $(TARGET_DIR)/chroot/chromeos/tmp

	# libcurl.so.4 in ChromeOS expected Equifax cert with hash name 578d5c04.0
	# In chromeos version <= R42, it is expected in /etc/ssl/certs. The following
	# line can probably be removed eventually since it should no longer look for
	# the cert here, but is being kept here in the interim just in case.
	cp -fp $(TARGET_DIR)/etc/ssl/certs/ca-certificates.crt $(TARGET_DIR)/etc/ssl/certs/578d5c04.0
	# In chromeos version >= R44, it is expected in
	# /usr/share/chromeos-ca-certificates. The following lines create this
	# directory and copy the cert to it.
	mkdir -p $(TARGET_DIR)/chroot/chromeos/usr/share/chromeos-ca-certificates
	cp -fp $(TARGET_DIR)/etc/ssl/certs/ca-certificates.crt $(TARGET_DIR)/chroot/chromeos/usr/share/chromeos-ca-certificates/578d5c04.0
endef

define GOOGLE_BUFFET_CLEAN_CMDS
	rm -rf $(TARGET_DIR)/etc/dbus-1/system.d/org.chromium.Buffet.conf
	rm -rf $(TARGET_DIR)/etc/init.d/S86buffet
	rm -rf $(TARGET_DIR)/chroot/chromeos
endef

$(eval $(call GENTARGETS))
