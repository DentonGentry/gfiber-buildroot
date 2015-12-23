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

ROOTFS_GINSTALL_DEPENDENCIES = linux host-xz host-squashfs host-uboot-tools
ROOTFS_GINSTALL_VERSION = $(shell cat $(BINARIES_DIR)/version)
ROOTFS_GINSTALL_PLATFORMS = $(shell echo $(BR2_TARGET_GENERIC_PLATFORMS_SUPPORTED) | sed 's/[, ][, ]*/, /g' | tr a-z A-Z)
ROOTFS_BLACKLIST = $(shell cat $(TOPDIR)/fs/ginstall/gfmn/fileblacklist.txt)

ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
GFMN_LOADER_NAME = u-boot-prod
else
GFMN_LOADER_NAME = u-boot-dev
endif

GFMN_LOADER_DIR = $(shell echo $(BR2_TARGET_ROOTFS_GINSTALL_LOADER_DIR))
GFMN_LOADER := $(wildcard $(GFMN_LOADER_DIR)/$(GFMN_LOADER_NAME).bin)
GFMN_LOADER_SIG := $(wildcard $(GFMN_LOADER_DIR)/$(GFMN_LOADER_NAME).sig)

define ROOTFS_GINSTALL_CMD
	set -e; \
	set -x; \
	rm -f $(BINARIES_DIR)/MANIFEST && \
	echo 'installer_version: 4' >>$(BINARIES_DIR)/MANIFEST && \
	echo 'image_type: unlocked' >>$(BINARIES_DIR)/MANIFEST && \
	echo 'platforms: [GFMN100]' >>$(BINARIES_DIR)/MANIFEST && \
	echo 'version: $(value ROOTFS_GINSTALL_VERSION)' >>$(BINARIES_DIR)/MANIFEST && \
	cp -f $(value GFMN_LOADER) $(BINARIES_DIR)/loader.img && \
	cp -f $(value GFMN_LOADER_SIG) $(BINARIES_DIR)/loader.sig && \
	rm -rf $(BINARIES_DIR)/../target/tmp/* && \
	rm -f $(BINARIES_DIR)/rootfs.sqsh && \
	$(foreach f,$(ROOTFS_BLACKLIST),rm -f $(BINARIES_DIR)/../target/$(f)) && \
	cd $(BINARIES_DIR) && \
	$(HOST_DIR)/usr/bin/mksquashfs $(BINARIES_DIR)/../target/* rootfs.sqsh -b 32768 \
	    -all-root -pf $(TOPDIR)/fs/ginstall/gfmn/devsqsh.txt -comp xz -noappend && \
	$(HOST_DIR)/usr/bin/lzma -f -k -9 vmlinux.bin && \
	$(HOST_DIR)/usr/bin/mkimage -A $(BR2_ARCH) -O linux -T kernel -C lzma           \
				-a 0x`$(CROSS_COMPILE)readelf \
							-S $(BINARIES_DIR)/../build/linux-HEAD/vmlinux | \
							grep -F '[ 1] .text'	| \
							grep -o '8.*' |cut -d' ' -f1`  \
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
		MANIFEST loader.img loader.sig kernel.img rootfs.sqsh && \
	ln -sf '$(value ROOTFS_GINSTALL_VERSION).gi' latest.gi
endef

$(eval $(call ROOTFS_TARGET,ginstall))
