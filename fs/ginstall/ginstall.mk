#############################################################
#
# Google platform image creation
#
#############################################################

GINSTALL_UBI_UBINIZE_OPTS := -m $(BR2_TARGET_ROOTFS_GINSTALL_UBI_MINIOSIZE)
GINSTALL_UBI_UBINIZE_OPTS += -p $(BR2_TARGET_ROOTFS_GINSTALL_UBI_PEBSIZE)
ifneq ($(BR2_TARGET_ROOTFS_GINSTALL_UBI_SUBSIZE),0)
GINSTALL_UBI_UBINIZE_OPTS += -s $(BR2_TARGET_ROOTFS_GINSTALL_UBI_SUBSIZE)
endif

ROOTFS_GINSTALL_DEPENDENCIES = rootfs-squashfs host-mtd

# TODO(sledbetter): remove vmlinuz gen after merging buildroot 2012.02+
define ROOTFS_GINSTALL_CMD
	gzip -c <$(BINARIES_DIR)/vmlinux >$(BINARIES_DIR)/vmlinuz; \
	chmod 0644 $(BINARIES_DIR)/vmlinuz; \
	( \
		echo "[vmlinuz]"; \
		cat fs/ginstall/ubinize.cfg; \
		echo "image=$(BINARIES_DIR)/vmlinuz"; \
		echo "vol_name=kernel"; \
	) >$(BUILD_DIR)/kernel_ubinize.cfg; \
	$(HOST_DIR)/usr/sbin/ubinize \
		-o $(BINARIES_DIR)/vmlinuz.ubi \
		$(GINSTALL_UBI_UBINIZE_OPTS) \
		$(BUILD_DIR)/kernel_ubinize.cfg; \
	( \
		echo "[rootfs]"; \
		cat fs/ginstall/ubinize.cfg; \
		echo "image=$(BINARIES_DIR)/rootfs.squashfs"; \
		echo "vol_name=rootfs"; \
	) >$(BUILD_DIR)/rootfs_ubinize.cfg; \
	$(HOST_DIR)/usr/sbin/ubinize \
		-o $(BINARIES_DIR)/rootfs.squashfs_ubi \
		$(GINSTALL_UBI_UBINIZE_OPTS) \
		$(BUILD_DIR)/rootfs_ubinize.cfg; \
	cd $(BINARIES_DIR) && \
	tar -czf bruno-$(shell cat $(BINARIES_DIR)/version).gi \
		version loader.bin vmlinuz rootfs.squashfs_ubi && \
	ln -sf bruno-$(shell cat $(BINARIES_DIR)/version).gi \
		bruno_ginstall_image.tgz
endef

$(eval $(call ROOTFS_TARGET,ginstall))
