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
	\
	echo "[vmlinuz]" > ./kernel_ubinize.cfg; \
	cat fs/ginstall/ubinize.cfg >> ./kernel_ubinize.cfg; \
	echo "image=$(BINARIES_DIR)/vmlinuz" >> ./kernel_ubinize.cfg; \
	echo "vol_name=kernel" >> ./kernel_ubinize.cfg; \
	$(HOST_DIR)/usr/sbin/ubinize -o $(BINARIES_DIR)/vmlinuz.ubi \
		$(GINSTALL_UBI_UBINIZE_OPTS) ./kernel_ubinize.cfg; \
	\
	echo "[rootfs]" > ./rootfs_ubinize.cfg; \
	cat fs/ginstall/ubinize.cfg >> ./rootfs_ubinize.cfg; \
	echo "image=$(BINARIES_DIR)/rootfs.squashfs" >> ./rootfs_ubinize.cfg; \
	echo "vol_name=rootfs" >> ./rootfs_ubinize.cfg; \
	$(HOST_DIR)/usr/sbin/ubinize -o $(BINARIES_DIR)/rootfs.squashfs_ubi \
		$(GINSTALL_UBI_UBINIZE_OPTS) ./rootfs_ubinize.cfg; \
	\
	tar zvPc --transform "s,$$(BINARIES_DIR)/,," \
		-f  $(BINARIES_DIR)/bruno_ginstall_image.tgz \
		$(BINARIES_DIR)/version \
		$(BINARIES_DIR)/loader.bin \
		$(BINARIES_DIR)/vmlinuz \
		$(BINARIES_DIR)/rootfs.squashfs_ubi; \
	rm kernel_ubinize.cfg
endef

$(eval $(call ROOTFS_TARGET,ginstall))
