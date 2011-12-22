#############################################################
#
# vmlinuz (compressed vmlinux)
#
#############################################################
GOOGLE_VMLINUZ_SITE=repo://vendor/google/platform
GOOGLE_VMLINUZ_DEPENDENCIES=linux host-mtd
GOOGLE_VMLINUZ_INSTALL_STAGING=NO
GOOGLE_VMLINUZ_INSTALL_TARGET=YES

UBI_UBINIZE_OPTS := -m $(BR2_TARGET_ROOTFS_UBIFS_MINIOSIZE)
UBI_UBINIZE_OPTS += -p $(BR2_TARGET_ROOTFS_UBI_PEBSIZE)
ifneq ($(BR2_TARGET_ROOTFS_UBI_SUBSIZE),0)
 UBI_UBINIZE_OPTS += -s $(BR2_TARGET_ROOTFS_UBI_SUBSIZE)
endif

define GOOGLE_VMLINUZ_INSTALL_TARGET_CMDS
	cp package/google/vmlinuz/kernel_ubinize.cfg ${BINARIES_DIR}/kernel_ubinize.cfg
	(cd ${BINARIES_DIR} ; \
	 gzip -9 < vmlinux > vmlinuz ; \
	 $(HOST_DIR)/usr/sbin/ubinize -o vmlinuz.ubi $(UBI_UBINIZE_OPTS) kernel_ubinize.cfg)
	rm ${BINARIES_DIR}/kernel_ubinize.cfg
endef

$(eval $(call GENTARGETS,package/google,google_vmlinuz))
