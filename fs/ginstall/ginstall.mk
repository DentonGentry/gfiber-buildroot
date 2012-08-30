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

ROOTFS_GINSTALL_DEPENDENCIES = rootfs-squashfs host-mtd host-dmverity \
			       host-google_signing

ROOTFS_GINSTALL_VERSION = "$$\(cat $(BINARIES_DIR)/version\)"

# TODO(sledbetter): remove vmlinuz gen after merging buildroot 2012.02+
define ROOTFS_GINSTALL_CMD
	set -e; \
	gzip -c <$(BINARIES_DIR)/vmlinux \
		>$(BINARIES_DIR)/vmlinuz_unsigned && \
	chmod 0644 $(BINARIES_DIR)/vmlinuz_unsigned && \
	cp $(BINARIES_DIR)/vmlinuz_unsigned $(BINARIES_DIR)/vmlinuz && \
	( \
		export LD_PRELOAD=; $(call HOST_GOOGLE_SIGNING_SIGN); \
	) && \
	cd $(BINARIES_DIR) && \
	tar -czf $(value ROOTFS_GINSTALL_VERSION).gi \
		version loader.bin loader.sig vmlinuz rootfs.squashfs
endef

$(eval $(call ROOTFS_TARGET,ginstall))
