#############################################################
#
# cpio to archive target filesystem
#
#############################################################

ROOTFS_CPIO_DIR=$(BUILD_DIR)/rootfs-cpio

ifeq ($(BR2_ROOTFS_DEVICE_CREATION_STATIC),y)

define ROOTFS_CPIO_ADD_INIT
        if [ ! -e $(TARGET_DIR)/init ]; then \
                ln -sf sbin/init $(ROOTFS_CPIO_DIR)/init; \
        fi
endef

else
# devtmpfs does not get automounted when initramfs is used.
# Add a pre-init script to mount it before running init
define ROOTFS_CPIO_ADD_INIT
        if [ ! -e $(TARGET_DIR)/init ]; then \
                $(INSTALL) -m 0755 fs/cpio/init $(ROOTFS_CPIO_DIR)/init; \
        fi
endef

endif # BR2_ROOTFS_DEVICE_CREATION_STATIC

define ROOTFS_CPIO_CMD
	mkdir -p $(ROOTFS_CPIO_DIR); \
	$(call ROOTFS_CPIO_ADD_INIT); \
	cd $(ROOTFS_CPIO_DIR) && find . | cpio --quiet -o -H newc -O $$@; \
	cd $(TARGET_DIR) && find . | cpio --quiet -o -H newc -O $$@ --append
endef

$(eval $(call ROOTFS_TARGET,cpio))
