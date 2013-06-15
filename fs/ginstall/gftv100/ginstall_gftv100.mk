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

ROOTFS_GINSTALL_VERSION = "$$\(cat $(BINARIES_DIR)/version\)"

ifeq ($(BR2_ARCH),mips)

BRUNO_CFE_DIR = ../vendor/broadcom/cfe-bin
ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
_BRUNO_LOADER = cfe_signed_release
else ifeq ($(BR2_PACKAGE_GOOGLE_OPENBOX),y)
_BRUNO_LOADER = cfe_signed_openbox
else
_BRUNO_LOADER = cfe_signed_unlocked
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

endif  # mips

ifeq ($(BR2_LINUX_KERNEL_ZIMAGE),y)
ROOTFS_GINSTALL_KERNEL_FILE=uImage
else
ROOTFS_GINSTALL_KERNEL_FILE=vmlinuz
endif

# TODO(apenwarr): update uboot to handle kernels with dmverity in them.
#  Right now our uboot doesn't understand the google verity header added
#  by GOOGLE_SIGNING (repack.py).
define ROOTFS_GINSTALL_CMD
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

$(eval $(call ROOTFS_TARGET,ginstall))
