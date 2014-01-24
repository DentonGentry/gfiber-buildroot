SIMPLERAMFS_SITE=null
SIMPLERAMFS_SOURCE=null
SIMPLERAMFS_VERSION=HEAD

SIMPLERAMFS_INSTALL_TARGET=NO
SIMPLERAMFS_INSTALL_IMAGES=YES

SIMPLERAMFS_DEPENDENCIES= \
	dash \
	toybox \
	toolbox \
	util-linux \
	lvm2 \
	google_signing \
	mtd

ifeq ($(BR2_PACKAGE_GOOGLE_HNVRAM),y)
SIMPLERAMFS_DEPENDENCIES+=google_hnvram
HNVRAM_BIN=$(TARGET_DIR)/usr/bin/hnvram
endif
ifeq ($(BR2_PACKAGE_MINDSPEED_DRIVERS),y)
SIMPLERAMFS_DEPENDENCIES+=mindspeed_drivers
endif
ifeq ($(BR2_PACKAGE_GPTFDISK_SGDISK),y)
SIMPLERAMFS_DEPENDENCIES+=gptfdisk
SGDISK_BIN=$(TARGET_DIR)/usr/sbin/sgdisk
endif
ifeq ($(BR2_PACKAGE_UTIL_LINUX_MOUNT),y)
SIMPLERAMFS_DEPENDENCIES+=util-linux
LOSETUP_BIN=$(TARGET_DIR)/sbin/losetup
endif

define SIMPLERAMFS_EXTRACT_CMDS
	mkdir -p $(@D)
endef

ifeq ($(BR2_TOOLCHAIN_EXTERNAL_GLIBC),y)
SIMPLERAMFS_LD_LINUX = $(TARGET_DIR)/lib/ld-linux.so.2
else
SIMPLERAMFS_LD_LINUX = $(TARGET_DIR)/lib/ld-uClibc.so.0
endif

define SIMPLERAMFS_BUILD_CMDS
	rm -rf $(@D)/fs
	for d in sbin bin lib proc dev sys rootfs mnt tmp vfat; do \
		mkdir -p $(@D)/fs/$$d; \
	done

	# the initramfs /init script, executed by the kernel by default
	ln -f \
		fs/simpleramfs/init \
		fs/simpleramfs/recover \
		fs/simpleramfs/mounts-sys \
		fs/simpleramfs/mounts-root \
		fs/simpleramfs/helpers.sh \
		$(@D)/fs/
	ln -s lib $(@D)/fs/lib64

	# toolbox/toybox symlinks
	#TODO(apenwarr): not sure we're actually using toolbox in simpleramfs.
	set -e; \
	cat $(TOOLBOX_DIR)/symlinks.list | \
		while read name; do \
			echo toolbox: $$name; \
			ln -sf toolbox $(@D)/fs/bin/$$name; \
		done
	set -e; \
	$(TOYBOX_DIR)/instlist | \
		while read name; do \
			echo toybox: $$name; \
			ln -sf toybox $(@D)/fs/bin/$$name; \
		done

	# other required binaries.
	ln -f $(TARGET_DIR)/bin/dash $(@D)/fs/bin/sh
	ln -f 	$(TARGET_DIR)/bin/toolbox \
		$(TARGET_DIR)/bin/toybox \
		$(TARGET_DIR)/usr/sbin/ubiattach \
		$(TARGET_DIR)/usr/sbin/ubidetach \
		$(TARGET_DIR)/usr/sbin/dmsetup \
		$(TARGET_DIR)/usr/sbin/readverity \
		$(TARGET_DIR)/sbin/switch_root \
		$(HNVRAM_BIN) \
		$(SGDISK_BIN) \
		$(LOSETUP_BIN) \
		$(@D)/fs/bin/

	# driver firmware and modules
	ln -f	fs/skeleton/sbin/hotplug $(@D)/fs/sbin/
	if [ "$(BR2_PACKAGE_MINDSPEED_DRIVERS)" = "y" ]; then \
		mkdir -p $(@D)/fs/lib/modules $(@D)/fs/lib/firmware && \
		ln -f	$(TARGET_DIR)/lib/modules/*/extra/pfe.ko \
			$(@D)/fs/lib/modules/ && \
		ln -f	$(TARGET_DIR)/lib/firmware/*c2000*.elf \
			$(@D)/fs/lib/firmware/; \
	fi

	# strip all the binaries
	$(STRIPCMD) $(@D)/fs/bin/*

	# without ld.so, nothing works
	if [ "$(BR2_TOOLCHAIN_EXTERNAL_GLIBC)" = "y" ]; then \
		cp --no-dereference --preserve=links $(TARGET_DIR)/lib/ld-* \
			$(@D)/fs/lib/; \
	else \
		cp $(TARGET_DIR)/lib/ld-uClibc.so.0 \
			$(@D)/fs/lib/; \
	fi

	# find required shared libs, including libraries pulled in by
	# other libraries that were pulled in.  Three iterations seems to
	# be one more than we need at time of writing (2012/04/17) which
	# gives us a slight safety margin.
	set -e; \
	for i in 1 2 3; do \
		echo "Loop $$i:"; \
		$(TARGET_MAKE_ENV) $(TARGET_CROSS)readelf -d \
			$(@D)/fs/bin/* $(@D)/fs/lib/* | \
		perl -ne '/library:\s*\[([^\]]+)\]/i && print "$$1\n"' | \
		sort | uniq | \
		while read fn; do \
			[ ! -e $(@D)/fs/lib/$$fn ] || continue; \
			echo lib: $$fn; \
			[ -e $(TARGET_DIR)/lib/$$fn ] && \
				cp $(TARGET_DIR)/lib/$$fn $(@D)/fs/lib/ || \
				cp $(TARGET_DIR)/usr/lib/$$fn $(@D)/fs/lib/; \
		done; \
	done
endef

define SIMPLERAMFS_INSTALL_IMAGES_CMDS
	(cd $(@D)/fs && \
	 ((find; echo /dev/console; echo /dev/kmsg) | cpio -oH newc)) \
		>$(BINARIES_DIR)/simpleramfs.cpio.new
	mv $(BINARIES_DIR)/simpleramfs.cpio.new \
	   $(BINARIES_DIR)/simpleramfs.cpio
endef

$(eval $(call GENTARGETS))
