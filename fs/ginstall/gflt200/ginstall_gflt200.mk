#############################################################
#
# Google platform image creation for Prism platform
#
#############################################################

ROOTFS_GINSTALL_DEPENDENCIES = linux rootfs-initramfs

ROOTFS_GINSTALL_VERSION = "$$\(cat $(BINARIES_DIR)/version\)"

PRISM_LOADERS := u-boot-gflt200_400rd_A-MC_ddr3_spi.bin

define ROOTFS_GINSTALL_CMD
	set -e; \
	cd $(BINARIES_DIR) && \
	tar -cf $(value ROOTFS_GINSTALL_VERSION).gi \
		version $(value PRISM_LOADERS) uImage
endef

$(eval $(call ROOTFS_TARGET,ginstall))
