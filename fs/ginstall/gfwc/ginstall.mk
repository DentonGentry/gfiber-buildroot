#############################################################
#
# Google platform image creation for windcharger platforms.
#
#############################################################
# WARNING WARNING WARNING
#
# Because of how buildroot handles fs generation macros, it EATS DOUBLE
# QUOTES.  Use only single quotes in all shell commands in this file, or
# you'll get very weird, hard-to-find errors.

#Note(allanzhang), please don't use host-lzma, mismatch with qca uboot.
ROOTFS_GINSTALL_DEPENDENCIES = linux host-squashfs
ROOTFS_GINSTALL_VERSION = $(shell cat $(BINARIES_DIR)/version)
ROOTFS_GINSTALL_PLATFORMS = $(shell echo $(BR2_TARGET_GENERIC_PLATFORMS_SUPPORTED) | sed 's/[, ][, ]*/, /g' | tr a-z A-Z)

ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
GFWC_LOADER_NAME = u-boot-prod
else
GFWC_LOADER_NAME = u-boot-dev
endif

GFWC_LOADER_DIR = $(shell echo $(BR2_TARGET_ROOTFS_GINSTALL_LOADER_DIR))
GFWC_LOADER := $(wildcard $(GFWC_LOADER_DIR)/$(GFWC_LOADER_NAME).bin)
GFWC_LOADER_SIG := $(wildcard $(GFWC_LOADER_DIR)/$(GFWC_LOADER_NAME).sig)

QCA_DIR = $(shell echo $(BINARIES_DIR)/../build/qca95xx-HEAD/qca95xx)

define ROOTFS_GINSTALL_CMD
	set -e; \
	set -x; \
	rm -f $(BINARIES_DIR)/MANIFEST && \
	echo 'installer_version: 4' >>$(BINARIES_DIR)/MANIFEST && \
	echo 'image_type: unlocked' >>$(BINARIES_DIR)/MANIFEST && \
	echo 'platforms: [GFMN100]' >>$(BINARIES_DIR)/MANIFEST && \
	echo 'version: $(value ROOTFS_GINSTALL_VERSION)' >>$(BINARIES_DIR)/MANIFEST && \
	cp -f $(value GFWC_LOADER) $(BINARIES_DIR)/loader.img && \
	cp -f $(value GFWC_LOADER_SIG) $(BINARIES_DIR)/loader.sig && \
	rm -rf $(BINARIES_DIR)/../target/tmp/* && \
	rm -f $(BINARIES_DIR)/rootfs.sqsh && \
	cd $(BINARIES_DIR) && \
	$(HOST_DIR)/usr/bin/mksquashfs $(BINARIES_DIR)/../target/* rootfs.sqsh \
	    -all-root -pf $(QCA_DIR)/build/devsqsh.txt -comp lzma && \
	$(QCA_DIR)/apps/lzma457/CPP/7zip/Compress/LZMA_Alone/lzma e vmlinux.bin vmlinux.bin.lzma && \
	$(BINARIES_DIR)/../build/uboot-HEAD/tools/mkimage \
        -A $(BR2_ARCH) -O linux -T kernel -C lzma -a 80002000 \
				-e `$(CROSS_COMPILE)readelf \
							-h $(BINARIES_DIR)/../build/linux-HEAD/vmlinux | \
							grep 'Entry point address' | \
							grep -o '0x.*'` \
				-n 'Linux Kernel Image' \
        -d vmlinux.bin.lzma uImage && \
	cp uImage kernel.img && \
	(echo -n 'kernel.img-sha1: ' && sha1sum kernel.img | cut -c1-40 && \
	 echo -n 'loader.img-sha1: ' && sha1sum loader.img | cut -c1-40 && \
	 echo -n 'rootfs.sqsh-sha1: ' && sha1sum rootfs.sqsh | cut -c1-40;) >>MANIFEST && \
	tar -cf $(value ROOTFS_GINSTALL_VERSION).gi \
		MANIFEST loader.img loader.sig kernel.img rootfs.sqsh
endef

$(eval $(call ROOTFS_TARGET,ginstall))
