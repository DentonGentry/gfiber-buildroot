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


ROOTFS_GINSTALL_DEPENDENCIES = linux
ROOTFS_GINSTALL_VERSION = $(shell cat $(BINARIES_DIR)/version)
ROOTFS_GINSTALL_PLATFORMS = $(shell echo $(BR2_TARGET_GENERIC_PLATFORMS_SUPPORTED) | sed 's/[, ][, ]*/, /g' | tr a-z A-Z)
GFWC_LOADER := u-boot.bin
QCA_DIR = $(shell echo $(BINARIES_DIR)/../build/qca95xx-HEAD/qca95xx)

define ROOTFS_GINSTALL_CMD
	set -e; \
	set -x; \
	rm -f $(BINARIES_DIR)/manifest && \
	echo 'installer_version: 3' >>$(BINARIES_DIR)/manifest && \
	echo 'image_type: unlocked' >>$(BINARIES_DIR)/manifest && \
	echo 'platforms: [GFMN100]' >>$(BINARIES_DIR)/manifest && \
	echo 'version: $(value ROOTFS_GINSTALL_VERSION)' >>$(BINARIES_DIR)/manifest && \
	cd $(BINARIES_DIR) && \
	cp $(value GFWC_LOADER) loader.img && \
	cp $(QCA_DIR)/apps/busybox-1.01/busybox ../target/bin/busybox && \
	mksquashfs $(BINARIES_DIR)/../target/* rootfs.sqsh -all-root -pf $(QCA_DIR)/build/devsqsh.txt && \
        $(QCA_DIR)/apps/lzma457/CPP/7zip/Compress/LZMA_Alone/lzma e vmlinux.bin vmlinux.bin.lzma && \
	$(BINARIES_DIR)/../build/uboot-HEAD/tools/mkimage \
        -A $(BR2_ARCH) -O linux -T kernel -C lzma -a 80002000 -e 0x801b8d40 \
	-n 'Linux Kernel Image' \
        -d vmlinux.bin.lzma uImage && \
	cp uImage kernel.img && \
	(echo -n 'kernel.img-sha1: ' && sha1sum kernel.img | cut -c1-40 && \
	 echo -n 'loader.img-sha1: ' && sha1sum loader.img | cut -c1-40 && \
	 echo -n 'rootfs.sqsh-sha1: ' && sha1sum rootfs.sqsh | cut -c1-40;) >>manifest && \
	tar -cf $(value ROOTFS_GINSTALL_VERSION).gi \
		manifest version loader.img kernel.img rootfs.sqsh
endef

$(eval $(call ROOTFS_TARGET,ginstall))
