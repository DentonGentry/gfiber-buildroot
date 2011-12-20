#############################################################
#
# Embed the squashfs image into a ubi container
#
#############################################################

UBI_UBINIZE_OPTS := -m $(BR2_TARGET_ROOTFS_UBIFS_MINIOSIZE)
UBI_UBINIZE_OPTS += -p $(BR2_TARGET_ROOTFS_UBI_PEBSIZE)
ifneq ($(BR2_TARGET_ROOTFS_UBI_SUBSIZE),0)
UBI_UBINIZE_OPTS += -s $(BR2_TARGET_ROOTFS_UBI_SUBSIZE)
endif

ROOTFS_SQUASHFS_UBI_DEPENDENCIES = rootfs-ubifs

define ROOTFS_SQUASHFS_UBI_CMD
	cp fs/ubifs/ubinize.cfg . ;\
	echo "image=$(BINARIES_DIR)/rootfs.squashfs" >> ./ubinize.cfg ;\
	echo "$(HOST_DIR)/usr/sbin/ubinize -o $$@ $(UBI_UBINIZE_OPTS) ubinize.cfg" ;\
	$(HOST_DIR)/usr/sbin/ubinize -o $$@ $(UBI_UBINIZE_OPTS) ubinize.cfg ;\
	rm ubinize.cfg
endef

$(eval $(call ROOTFS_TARGET,squashfs_ubi))
