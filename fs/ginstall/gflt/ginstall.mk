#############################################################
#
# Google platform image creation for gflt platforms.
#
#############################################################
# WARNING WARNING WARNING
#
# Because of how buildroot handles fs generation macros, it EATS DOUBLE
# QUOTES.  Use only single quotes in all shell commands in this file, or
# you'll get very weird, hard-to-find errors.


ROOTFS_GINSTALL_DEPENDENCIES = linux rootfs-initramfs
ROOTFS_GINSTALL_VERSION = $(shell cat $(BINARIES_DIR)/version)
ROOTFS_GINSTALL_PLATFORMS = $(shell echo $(BR2_TARGET_GENERIC_PLATFORMS_SUPPORTED) | sed 's/[, ][, ]*/, /g' | tr a-z A-Z)

ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
GFLT_LOADER := $(BR2_TARGET_ROOTFS_GINSTALL_LOADER_DIR)/u-boot-spi-prod.bin
else
GFLT_LOADER := $(BR2_TARGET_ROOTFS_GINSTALL_LOADER_DIR)/u-boot-spi-dev.bin
endif

GFLT_SIG := $(patsubst %.bin,%.sig,$(GFLT_LOADER))


define ROOTFS_GINSTALL_CMD
	set -e; \
	set -x; \
	cp -f $(value GFLT_LOADER) $(BINARIES_DIR) && \
	cp -f $(value GFLT_SIG) $(BINARIES_DIR) && \
	cp -f $(value GFLT_LOADER) $(BINARIES_DIR)/loader.img && \
	cp -f $(value GFLT_SIG) $(BINARIES_DIR)/loader.sig && \
	rm -f $(BINARIES_DIR)/manifest && \
	echo 'installer_version: 3' >>$(BINARIES_DIR)/manifest && \
	echo 'image_type: unlocked' >>$(BINARIES_DIR)/manifest && \
	echo 'platforms: [GFLT110]' >>$(BINARIES_DIR)/manifest && \
	echo 'version: $(value ROOTFS_GINSTALL_VERSION)' >>$(BINARIES_DIR)/manifest && \
	cd $(BINARIES_DIR) && \
	gzip -c <rootfs.cpio >rootfs.cpio.gz && \
	$(HOST_DIR)/usr/bin/mkimage \
        -A $(BR2_ARCH) -O linux -T kernel -C none \
        -a 0x00008000 -e 0x00008000 -n $(value ROOTFS_GINSTALL_VERSION) \
        -d zImage uImage && \
	cp uImage kernel.img && \
	(echo -n 'kernel.img-sha1: ' && sha1sum kernel.img | cut -c1-40 && \
	 echo -n 'loader.img-sha1: ' && sha1sum loader.img | cut -c1-40;) >>manifest && \
	tar -cf $(value ROOTFS_GINSTALL_VERSION).gi \
		manifest version loader.img loader.sig kernel.img
endef

$(eval $(call ROOTFS_TARGET,ginstall))
