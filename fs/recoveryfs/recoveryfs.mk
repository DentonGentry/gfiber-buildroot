ROOTFS_RECOVERYFS_DEPENDENCIES = simpleramfs rootfs-squashfs

ROOTFS_RECOVERYFS_DIR=$(BUILD_DIR)/rootfs-recoveryfs
FS=$(ROOTFS_RECOVERYFS_DIR)/fs

define ROOTFS_RECOVERYFS_CMD
	rm -rf $(FS); \
	set -e; \
	mkdir -p $(FS) && \
	cd $(FS) && \
	cpio -i < $(BINARIES_DIR)/simpleramfs.cpio && \
	cp $(BINARIES_DIR)/rootfs.squashfs $(FS)/rootfs.img && \
	(find; echo /dev/console; echo /dev/kmsg) | cpio -oH newc > $(ROOTFS_RECOVERYFS_DIR)/recoveryfs.cpio && \
	cp $(ROOTFS_RECOVERYFS_DIR)/recoveryfs.cpio $(BINARIES_DIR)
endef

$(eval $(call ROOTFS_TARGET,recoveryfs))
