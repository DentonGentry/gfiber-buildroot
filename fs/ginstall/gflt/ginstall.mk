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
ROOTFS_GINSTALL_MODELS = $(shell echo $(BR2_TARGET_GENERIC_PLATFORMS_SUPPORTED) | sed 's/[, ][, ]*/ /g' | tr A-Z a-z)

ROOTFS_GINSTALL_DIR = $(call qstrip,$(BR2_TARGET_ROOTFS_GINSTALL_LOADER_DIR))
ROOTFS_GINSTALL_ARCH = $(call qstrip,$(BR2_ARCH))

ifeq ($(BR2_PACKAGE_GOOGLE_PROD),y)
ROOTFS_GINSTALL_LOADER = u-boot-spi-prod.bin
else
ROOTFS_GINSTALL_LOADER = u-boot-spi-dev.bin
endif
ROOTFS_GINSTALL_SIG = $(patsubst %.bin,%.sig,$(ROOTFS_GINSTALL_LOADER))

ROOTFS_GINSTALL_LOADERBINS = $(foreach model,$(ROOTFS_GINSTALL_MODELS),loader.$(model).bin)
ROOTFS_GINSTALL_LOADERSIGS = $(patsubst %.bin,%.sig,$(ROOTFS_GINSTALL_LOADERBINS))

define ROOTFS_GINSTALL_CMD
	set -ex -o pipefail; \
	rm -f $(BINARIES_DIR)/loaders-sha && \
	for m in $(ROOTFS_GINSTALL_MODELS); do \
		set -e -o pipefail && \
		c=\"cp -f $(ROOTFS_GINSTALL_DIR)/\$$$$m/$(ROOTFS_GINSTALL_LOADER) $(BINARIES_DIR)/loader.\$$$$m.bin\" && \
		echo \"running: \$$$$c\" && \$$$$c && \
		c=\"cp -f $(ROOTFS_GINSTALL_DIR)/\$$$$m/$(ROOTFS_GINSTALL_SIG) $(BINARIES_DIR)/loader.\$$$$m.sig\" && \
		echo \"running: \$$$$c\" && \$$$$c && \
		c=\"echo loader.\$$$$m.bin-sha1: \$$$$(sha1sum $(BINARIES_DIR)/loader.\$$$$m.bin | cut -c1-40)\" && \
		echo \"running: \$$$$c\" && \$$$$c >>$(BINARIES_DIR)/loaders-sha; \
	done && \
	rm -f $(BINARIES_DIR)/manifest && \
	echo 'multiloader: 1' >>$(BINARIES_DIR)/manifest && \
	echo 'installer_version: 3' >>$(BINARIES_DIR)/manifest && \
	echo 'image_type: unlocked' >>$(BINARIES_DIR)/manifest && \
	echo 'platforms: [ $(ROOTFS_GINSTALL_PLATFORMS) ]' >>$(BINARIES_DIR)/manifest && \
	echo 'version: $(value ROOTFS_GINSTALL_VERSION)' >>$(BINARIES_DIR)/manifest && \
	cd $(BINARIES_DIR) && \
	gzip -c <rootfs.cpio >rootfs.cpio.gz && \
	$(HOST_DIR)/usr/bin/mkimage \
		-A $(ROOTFS_GINSTALL_ARCH) -O linux -T kernel -C none \
		-a 0x00008000 -e 0x00008000 -n $(value ROOTFS_GINSTALL_VERSION) \
		-d zImage uImage && \
	cp uImage kernel.img && \
	(echo -n 'kernel.img-sha1: ' && sha1sum kernel.img | cut -c1-40;) >>manifest && \
	cat loaders-sha >>manifest && \
	tar -cf $(value ROOTFS_GINSTALL_VERSION).gi \
		manifest version $(ROOTFS_GINSTALL_LOADERBINS) $(ROOTFS_GINSTALL_LOADERSIGS) kernel.img && \
	ln -sf '$(value ROOTFS_GINSTALL_VERSION).gi' latest.gi
endef

$(eval $(call ROOTFS_TARGET,ginstall))
