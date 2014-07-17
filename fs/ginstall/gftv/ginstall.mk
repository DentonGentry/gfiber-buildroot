# Google platform image creation for Bruno platform
#
#
# WARNING WARNING WARNING
#
# Because of how buildroot handles fs generation macros, it EATS DOUBLE
# QUOTES.  Use only single quotes in all shell commands in this file, or
# you'll get very weird, hard-to-find errors.

ROOTFS_GINSTALL_DEPENDENCIES = simpleramfs rootfs-squashfs host-mtd \
				host-dmverity host-google_signing

ROOTFS_GINSTALL_VERSION = $(shell cat $(BINARIES_DIR)/version)
ROOTFS_GINSTALL_PLATFORMS = $(shell echo $(BR2_TARGET_GENERIC_PLATFORMS_SUPPORTED) | sed 's/[, ][, ]*/, /g' | tr a-z A-Z)

ifeq ($(ARCH),mipsel)
# Config strings have quotes around them for some reason, which causes
# trouble.  This trick removes them.
BRUNO_CFE_DIR = $(shell echo $(BR2_TARGET_ROOTFS_GINSTALL_LOADER_DIR))
ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
_BRUNO_LOADER = cfe_signed_release
ROOTFS_GINSTALL_TYPE=prod
else ifeq ($(BR2_PACKAGE_GOOGLE_OPENBOX),y)
_BRUNO_LOADER = cfe_signed_openbox
ROOTFS_GINSTALL_TYPE=openbox
else
_BRUNO_LOADER = cfe_signed_unlocked
ROOTFS_GINSTALL_TYPE=unlocked
endif

# These will be blank if the given files don't exist (eg. if you don't have
# access to the right repositories) and then we'll just leave them out of
# the build.  The resulting image will not contain a bootloader, which is
# ok; we'll just leave the existing bootloader in place.
BRUNO_LOADER     := $(wildcard $(BRUNO_CFE_DIR)/$(_BRUNO_LOADER).bin)
BRUNO_LOADER_SIG := $(wildcard $(BRUNO_CFE_DIR)/$(_BRUNO_LOADER).sig)
ifneq ($(BRUNO_LOADER),)
# We intentionally changed the filenames from v2 to v3 to prevent really
# harmful installs due to accidental half-compatibility.
BRUNO_LOADERS_V2 := loader.bin loader.sig
BRUNO_LOADERS_V3_V4 := loader.img loader.sig
endif

endif  # mipsel

ifeq ($(ARCH),arm)
# Config strings have quotes around them for some reason, which causes
# trouble.  This trick removes them.
LOADER_DIR = $(shell echo $(BR2_TARGET_ROOTFS_GINSTALL_LOADER_DIR))

ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
_BAREBOX = barebox_signed_release
ROOTFS_GINSTALL_TYPE=prod
else
_BAREBOX = barebox_signed_unlocked
ROOTFS_GINSTALL_TYPE=unlocked
endif
_ULOADER = uloader_signed_release

# These will be blank if the given files don't exist (eg. if you don't have
# access to the right repositories) and then we'll just leave them out of
# the build.  The resulting image will not contain a bootloader, which is
# ok; we'll just leave the existing bootloader in place.
BAREBOX     := $(wildcard $(LOADER_DIR)/$(_BAREBOX).bin)
BAREBOX_SIG := $(wildcard $(LOADER_DIR)/$(_BAREBOX).sig)

ULOADER     := $(wildcard $(LOADER_DIR)/$(_ULOADER).bin)
ULOADER_SIG := $(wildcard $(LOADER_DIR)/$(_ULOADER).sig)

ifneq ($(BAREBOX),)
BRUNO_LOADERS_V3_V4 := $(BRUNO_LOADERS_V3_V4) loader.img loader.sig
endif
ifneq ($(ULOADER),)
BRUNO_LOADERS_V3_V4 := $(BRUNO_LOADERS_V3_V4) uloader.img uloader.sig
endif

endif #arm

ifeq ($(BR2_LINUX_KERNEL_ZIMAGE),y)
ROOTFS_GINSTALL_KERNEL_FILE=uImage
else
ROOTFS_GINSTALL_KERNEL_FILE=vmlinuz
endif

# v3 and v4 image formats contain a manifest file, which describes the image
# and supported platforms.
#
# Note: need to use $(value XYZ) for XYZ variables that change during
# the build process (eg. because they read a file), since variable
# substitutions in this macro happen at macro define time, not
# runtime, unlike other make variables.
ifeq ($(BR2_TARGET_ROOTFS_GINSTALL_V4),y)
ROOTFS_GINSTALL_MANIFEST=MANIFEST
ROOTFS_GINSTALL_INSTALLER_VERSION=4
ROOTFS_GINSTALL_MINIMUM_VERSION=gfiber-39.1
else
ROOTFS_GINSTALL_MANIFEST=manifest
ROOTFS_GINSTALL_INSTALLER_VERSION=3
endif
define ROOTFS_GINSTALL_CMD_V3_V4
	set -e; \
	rm -f $(BINARIES_DIR)/$(ROOTFS_GINSTALL_MANIFEST) && \
	echo 'installer_version: $(ROOTFS_GINSTALL_INSTALLER_VERSION)' >>$(BINARIES_DIR)/$(ROOTFS_GINSTALL_MANIFEST) && \
	if [ '$(BR2_TARGET_ROOTFS_GINSTALL_V4)' = 'y' ]; then \
		echo 'minimum_version: $(ROOTFS_GINSTALL_MINIMUM_VERSION)' >>$(BINARIES_DIR)/$(ROOTFS_GINSTALL_MANIFEST); \
	fi && \
	echo 'image_type: $(ROOTFS_GINSTALL_TYPE)' >>$(BINARIES_DIR)/$(ROOTFS_GINSTALL_MANIFEST) && \
	echo 'version: $(value ROOTFS_GINSTALL_VERSION)' >>$(BINARIES_DIR)/$(ROOTFS_GINSTALL_MANIFEST) && \
	echo 'platforms: [ $(ROOTFS_GINSTALL_PLATFORMS) ]' >>$(BINARIES_DIR)/$(ROOTFS_GINSTALL_MANIFEST) && \
	if [ '$(BR2_LINUX_KERNEL_VMLINUX)' = 'y' ]; then \
		gzip -c <$(BINARIES_DIR)/vmlinux \
			>$(BINARIES_DIR)/vmlinuz_unsigned && \
		chmod 0644 $(BINARIES_DIR)/vmlinuz_unsigned && \
		if [ -e '$(BRUNO_LOADER)' ]; then \
			cp -f $(BRUNO_LOADER) $(BINARIES_DIR)/loader.img && \
			cp -f $(BRUNO_LOADER_SIG) $(BINARIES_DIR)/loader.sig; \
		fi && \
		cp $(BINARIES_DIR)/vmlinuz_unsigned $(BINARIES_DIR)/vmlinuz && \
		( \
			export LD_PRELOAD=; $(call HOST_GOOGLE_SIGNING_SIGN); \
		); \
	fi && \
	if [ '$(BR2_LINUX_KERNEL_ZIMAGE)' = 'y' ]; then \
		if [ -e '$(BAREBOX)' ]; then \
			cp $(BAREBOX) $(BINARIES_DIR)/loader.img && \
			cp $(BAREBOX_SIG) $(BINARIES_DIR)/loader.sig; \
		fi && \
		if [ -e '$(ULOADER)' ]; then \
			cp $(ULOADER) $(BINARIES_DIR)/uloader.img && \
			cp $(ULOADER_SIG) $(BINARIES_DIR)/uloader.sig; \
		fi; \
	fi && \
	cd $(BINARIES_DIR) && \
	ln -f rootfs.squashfs rootfs.img && \
	gzip -c <simpleramfs.cpio >simpleramfs.cpio.gz && \
	if [ '$(BR2_LINUX_KERNEL_ZIMAGE)' = 'y' ]; then \
		$(HOST_DIR)/usr/bin/mkimage \
			-A $(BR2_ARCH) -O linux -T multi -C none \
			-a 0x03008000 -e 0x03008000 -n Linux \
			-d zImage:simpleramfs.cpio.gz \
			uImage; \
	fi && \
	ln -f $(ROOTFS_GINSTALL_KERNEL_FILE) kernel.img && \
	(echo -n 'rootfs.img-sha1: ' && sha1sum rootfs.img | cut -c1-40 && \
	 echo -n 'kernel.img-sha1: ' && sha1sum kernel.img | cut -c1-40 && \
	 if [ -e '$(BRUNO_LOADER)' ]; then \
	   echo -n 'loader.img-sha1: ' && sha1sum loader.img | cut -c1-40 && \
	   echo -n 'loader.sig-sha1: ' && sha1sum loader.sig | cut -c1-40; \
	 fi ) >>$(ROOTFS_GINSTALL_MANIFEST) && \
	tar -cf '$(value ROOTFS_GINSTALL_VERSION).gi' \
		$(ROOTFS_GINSTALL_MANIFEST) \
		$(BRUNO_LOADERS_V3_V4) \
		kernel.img \
		rootfs.img
endef

# v2 image format was used at launch of GFiber TV devices.
# it contains only a version file, and no provision for
# specifying platform compatibility
define ROOTFS_GINSTALL_CMD_V2
	set -e; \
	if [ '$(BR2_LINUX_KERNEL_VMLINUX)' = 'y' ]; then \
		gzip -c <$(BINARIES_DIR)/vmlinux \
			>$(BINARIES_DIR)/vmlinuz_unsigned && \
		chmod 0644 $(BINARIES_DIR)/vmlinuz_unsigned && \
		if [ -e '$(BRUNO_LOADER)' ]; then \
			cp -f $(BRUNO_LOADER) $(BINARIES_DIR)/loader.bin && \
			cp -f $(BRUNO_LOADER_SIG) $(BINARIES_DIR)/loader.sig; \
		fi && \
		cp $(BINARIES_DIR)/vmlinuz_unsigned $(BINARIES_DIR)/vmlinuz && \
		( \
			export LD_PRELOAD=; $(call HOST_GOOGLE_SIGNING_SIGN); \
		); \
	fi && \
	cd $(BINARIES_DIR) && \
	gzip -c <simpleramfs.cpio >simpleramfs.cpio.gz && \
	tar -cf $(value ROOTFS_GINSTALL_VERSION).gi \
		version \
		$(BRUNO_LOADERS_V2) \
		vmlinuz \
		rootfs.squashfs
endef

ifeq ($(BR2_TARGET_ROOTFS_GINSTALL_V3)$(BR2_TARGET_ROOTFS_GINSTALL_V4),y)
ROOTFS_GINSTALL_CMD=$(ROOTFS_GINSTALL_CMD_V3_V4)
else
ROOTFS_GINSTALL_CMD=$(ROOTFS_GINSTALL_CMD_V2)
endif

$(eval $(call ROOTFS_TARGET,ginstall))
