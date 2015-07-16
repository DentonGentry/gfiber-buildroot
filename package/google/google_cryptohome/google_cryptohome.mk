#############################################################
#
# google_cryptohome
#
#############################################################

CRYPTOHOME_CHROMEOS_VERSION = R44-7077
GOOGLE_CRYPTOHOME_SITE = repo://vendor/google/tarballs

define GOOGLE_CRYPTOHOME_INSTALL_TARGET_CMDS
	# Untar and place the chromeos rootdir under /chroot
	mkdir -p $(TARGET_DIR)/chroot
	tar -zxvf $(@D)/google_cryptohome-$(CRYPTOHOME_CHROMEOS_VERSION).tar.gz -C $(TARGET_DIR)/chroot
	# Copy configuration file
	$(INSTALL) -m 0644 -D package/google/google_cryptohome/tcsd.conf $(TARGET_DIR)/etc
	# Copy Hardware-ID
	mkdir -p $(TARGET_DIR)/chroot/chromeos/proc/device-tree/firmware/chromeos/
	$(INSTALL) -m 0644 -D package/google/google_cryptohome/hardware-id $(TARGET_DIR)/chroot/chromeos/proc/device-tree/firmware/chromeos/
	# Install /etc/init.d/S79cryptohome script
	mkdir -p $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 0755 -D package/google/google_cryptohome/S79cryptohome $(TARGET_DIR)/etc/init.d/S79cryptohome
	# Install customized dbus config to run in chroot.
	mkdir -p $(TARGET_DIR)/etc/dbus-1/system.d
	$(INSTALL) -m 0644 -D package/google/google_cryptohome/org.chromium.Chaps.conf $(TARGET_DIR)/etc/dbus-1/system.d/org.chromium.Chaps.conf
	$(INSTALL) -m 0644 -D package/google/google_cryptohome/org.chromium.Cryptohome.conf $(TARGET_DIR)/etc/dbus-1/system.d/org.chromium.Cryptohome.conf
	# Create chroot binding point for dbus
	mkdir -p $(TARGET_DIR)/chroot/chromeos/var/run
	# Create chroot binding points for cryptohome
	mkdir -p $(TARGET_DIR)/chroot/chromeos/var/lib
	mkdir -p $(TARGET_DIR)/chroot/chromeos/mnt/stateful_partition
	mkdir -p $(TARGET_DIR)/chroot/chromeos/etc
	mkdir -p $(TARGET_DIR)/chroot/chromeos/home
	mkdir -p $(TARGET_DIR)/chroot/chromeos/tmp
	mkdir -p $(TARGET_DIR)/chroot/chromeos/dev
	mkdir -p $(TARGET_DIR)/chroot/chromeos/sys
	mkdir -p $(TARGET_DIR)/chroot/chromeos/root
	# libcurl.so.4 in ChromeOS expected Equifax cert with hash name 578d5c04.0
	cp -p $(TARGET_DIR)/etc/ssl/certs/ca-certificates.crt $(TARGET_DIR)/etc/ssl/certs/578d5c04.0
endef

define GOOGLE_CRYPTOHOME_CLEAN_CMDS
	rm -rf $(TARGET_DIR)/etc/dbus-1/system.d/org.chromium.Chaps.conf
	rm -rf $(TARGET_DIR)/etc/dbus-1/system.d/org.chromium.Cryptohome.conf
	rm -rf $(TARGET_DIR)/etc/init.d/S79cryptohome
	rm -rf $(TARGET_DIR)/chroot/chromeos
endef

define GOOGLE_CRYPTOHOME_PERMISSIONS
	/etc/tcsd.conf f 0600 104 107 - - - - -
	$(SUDO_PERMS)
endef

$(eval $(call GENTARGETS))
