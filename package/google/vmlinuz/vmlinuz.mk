#############################################################
#
# vmlinuz (compressed vmlinux)
#
#############################################################
GOOGLE_VMLINUZ_SITE=repo://vendor/google/platform
GOOGLE_VMLINUZ_DEPENDENCIES=linux host-mtd
GOOGLE_VMLINUZ_INSTALL_STAGING=YES
GOOGLE_VMLINUZ_INSTALL_TARGET=NO

UBI_UBINIZE_OPTS := -m $(BR2_TARGET_ROOTFS_UBIFS_MINIOSIZE)
UBI_UBINIZE_OPTS += -p $(BR2_TARGET_ROOTFS_UBI_PEBSIZE)
ifneq ($(BR2_TARGET_ROOTFS_UBI_SUBSIZE),0)
 UBI_UBINIZE_OPTS += -s $(BR2_TARGET_ROOTFS_UBI_SUBSIZE)
endif

define GOOGLE_VMLINUZ_INSTALL_STAGING_CMDS
	cp package/google/vmlinuz/kernel_ubinize.cfg $(STAGING_DIR)/etc/kernel_ubinize.cfg
	echo $(UBI_UBINIZE_OPTS) > $(STAGING_DIR)/etc/kernel_ubi_opts
endef

$(eval $(call GENTARGETS,package/google,google_vmlinuz))
