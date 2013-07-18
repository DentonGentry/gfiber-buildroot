#############################################################
#
# Google platform image creation for Bruno platform
#
#############################################################

GINSTALL_UBI_UBINIZE_OPTS := -m $(BR2_TARGET_ROOTFS_GINSTALL_UBI_MINIOSIZE)
GINSTALL_UBI_UBINIZE_OPTS += -p $(BR2_TARGET_ROOTFS_GINSTALL_UBI_PEBSIZE)
ifneq ($(BR2_TARGET_ROOTFS_GINSTALL_UBI_SUBSIZE),0)
GINSTALL_UBI_UBINIZE_OPTS += -s $(BR2_TARGET_ROOTFS_GINSTALL_UBI_SUBSIZE)
endif

ROOTFS_GINSTALL_DEPENDENCIES = simpleramfs rootfs-squashfs host-mtd \
				host-dmverity host-google_signing

ROOTFS_GINSTALL_VERSION = $(shell cat $(BINARIES_DIR)/version)

ifeq ($(ARCH),mipsel)
BRUNO_CFE_DIR = ../vendor/broadcom/cfe-bin
ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
_BRUNO_LOADER = cfe_signed_release
IMAGE_TYPE=prod
else ifeq ($(BR2_PACKAGE_GOOGLE_OPENBOX),y)
_BRUNO_LOADER = cfe_signed_openbox
IMAGE_TYPE=openbox
else
_BRUNO_LOADER = cfe_signed_unlocked
IMAGE_TYPE=unlocked
endif

# These will be blank if the given files don't exist (eg. if you don't have
# access to the right repositories) and then we'll just leave them out of
# the build.  The resulting image will not contain a bootloader, which is
# ok; we'll just leave the existing bootloader in place.
BRUNO_LOADER     := $(wildcard $(BRUNO_CFE_DIR)/$(_BRUNO_LOADER).bin)
BRUNO_LOADER_SIG := $(wildcard $(BRUNO_CFE_DIR)/$(_BRUNO_LOADER).sig)
ifneq ($(BRUNO_LOADER),)
BRUNO_LOADERS := loader.bin loader.sig
endif

endif  # mipsel

ifeq ($(BR2_LINUX_KERNEL_ZIMAGE),y)
ROOTFS_GINSTALL_KERNEL_FILE=uImage
else ifeq ($(BR2_TARGET_ROOTFS_GINSTALL_V3),y)
ROOTFS_GINSTALL_KERNEL_FILE=kernel.img
else
ROOTFS_GINSTALL_KERNEL_FILE=vmlinuz
endif

# TODO(apenwarr): update uboot to handle kernels with dmverity in them.
#  Right now our uboot doesn't understand the google verity header added
#  by GOOGLE_SIGNING (repack.py).

# v3 image format contains a manifest file, which describes the image and
# supported platforms
define ROOTFS_GINSTALL_CMD_V3
	set -e; \
	rm -f $(BINARIES_DIR)/manifest && \
	echo "installer_version: 3" >>$(BINARIES_DIR)/manifest && \
	echo "image_type: $(IMAGE_TYPE)" >>$(BINARIES_DIR)/manifest && \
	echo "version: $(value ROOTFS_GINSTALL_VERSION)" >>$(BINARIES_DIR)/manifest && \
	echo "platforms: [ GFHD200 ]" >>$(BINARIES_DIR)/manifest && \
	if [ '$(BR2_LINUX_KERNEL_VMLINUX)' = 'y' ]; then \
		gzip -c <$(BINARIES_DIR)/vmlinux \
			>$(BINARIES_DIR)/vmlinuz_unsigned && \
		chmod 0644 $(BINARIES_DIR)/vmlinuz_unsigned && \
		if [ -e '$(value BRUNO_LOADER)' ]; then \
			cp -f $(BRUNO_LOADER) $(BINARIES_DIR)/loader.img && \
			cp -f $(BRUNO_LOADER_SIG) $(BINARIES_DIR)/loader.sig; \
		fi && \
		cp $(BINARIES_DIR)/vmlinuz_unsigned $(BINARIES_DIR)/vmlinuz && \
		( \
			export LD_PRELOAD=; $(call HOST_GOOGLE_SIGNING_SIGN); \
		); \
	fi && \
	cd $(BINARIES_DIR) && \
	ln -f rootfs.squashfs rootfs.img && \
	ln -f vmlinuz kernel.img && \
	gzip -c <simpleramfs.cpio >simpleramfs.cpio.gz && \
	if [ '$(BR2_LINUX_KERNEL_ZIMAGE)' = 'y' ]; then \
		$(HOST_DIR)/usr/bin/mkimage \
			-A $(BR2_ARCH) -O linux -T multi -C none \
			-a 0x03008000 -e 0x03008000 -n Linux \
			-d zImage:simpleramfs.cpio.gz \
			uImage; \
	fi && \
	tar -cf "$(value ROOTFS_GINSTALL_VERSION).gi" \
		manifest \
		$(BRUNO_LOADERS) \
		$(ROOTFS_GINSTALL_KERNEL_FILE) \
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
		if [ -e '$(value BRUNO_LOADER)' ]; then \
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
	if [ '$(BR2_LINUX_KERNEL_ZIMAGE)' = 'y' ]; then \
		$(HOST_DIR)/usr/bin/mkimage \
			-A $(BR2_ARCH) -O linux -T multi -C none \
			-a 0x03008000 -e 0x03008000 -n Linux \
			-d zImage:simpleramfs.cpio.gz \
			uImage; \
	fi && \
	tar -cf $(value ROOTFS_GINSTALL_VERSION).gi \
		version \
		$(BRUNO_LOADERS) \
		$(ROOTFS_GINSTALL_KERNEL_FILE) \
		rootfs.squashfs
endef

ifeq ($(BR2_TARGET_ROOTFS_GINSTALL_V3),y)
ROOTFS_GINSTALL_CMD=$(ROOTFS_GINSTALL_CMD_V3)
else
ROOTFS_GINSTALL_CMD=$(ROOTFS_GINSTALL_CMD_V2)
endif

$(eval $(call ROOTFS_TARGET,ginstall))
