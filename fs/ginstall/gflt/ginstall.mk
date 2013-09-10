#############################################################
#
# Google platform image creation for gflt platforms.
#
#############################################################

ROOTFS_GINSTALL_DEPENDENCIES = linux rootfs-initramfs

ROOTFS_GINSTALL_VERSION = "$$\(cat $(BINARIES_DIR)/version\)"

GFLT_LOADER := u-boot-spi.bin

define ROOTFS_GINSTALL_CMD
	set -e; \
	cd $(BINARIES_DIR) && \
	cp $(value GFLT_LOADER) loader.bin && \
	tar -cf $(value ROOTFS_GINSTALL_VERSION).gi \
		version loader.bin uImage
endef

$(eval $(call ROOTFS_TARGET,ginstall))
