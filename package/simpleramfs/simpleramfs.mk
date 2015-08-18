SIMPLERAMFS_SITE_METHOD=null

SIMPLERAMFS_INSTALL_TARGET=NO
SIMPLERAMFS_INSTALL_IMAGES=YES

SIMPLERAMFS_DEPENDENCIES= \
	dash \
	toybox \
	toolbox \
	util-linux \
	google_signing \
	google_platform \
	mtd

ifeq ($(BR2_PACKAGE_SIMPLERAMFS_FIRMWARE),y)
SIMPLERAMFS_DEPENDENCIES+=simpleramfs_firmware
endif

ifeq ($(BR2_PACKAGE_GOOGLE_HNVRAM),y)
SIMPLERAMFS_DEPENDENCIES+=google_hnvram
HNVRAM_BIN=$(TARGET_DIR)/usr/bin/hnvram
endif
ifeq ($(BR2_PACKAGE_MINDSPEED_DRIVERS),y)
SIMPLERAMFS_DEPENDENCIES+=mindspeed_drivers
endif
ifneq ($(BR2_TARGET_ROOTFS_RECOVERYFS),y)
ifeq ($(BR2_PACKAGE_GPTFDISK_SGDISK),y)
SIMPLERAMFS_DEPENDENCIES+=gptfdisk
SGDISK_BIN=$(TARGET_DIR)/usr/sbin/sgdisk
endif
endif
ifeq ($(BR2_PACKAGE_UTIL_LINUX_MOUNT),y)
SIMPLERAMFS_DEPENDENCIES+=util-linux
LOSETUP_BIN=$(TARGET_DIR)/sbin/losetup
endif
ifeq ($(BR2_PACKAGE_LVM2),y)
SIMPLERAMFS_DEPENDENCIES+=lvm2
DMSETUP_BIN=$(TARGET_DIR)/usr/sbin/dmsetup
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
	for d in sbin bin lib proc dev sys rootfs mnt tmp vfat veritytmp etc; do \
		mkdir -p $(@D)/fs/$$d; \
	done

	# the initramfs /init script, executed by the kernel by default
	ln -f \
		package/simpleramfs/init \
		package/simpleramfs/recover \
		package/simpleramfs/mounts-sys \
		package/simpleramfs/mounts-root \
		package/simpleramfs/helpers.sh \
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
		$(TARGET_DIR)/usr/sbin/nanddump \
		$(TARGET_DIR)/usr/sbin/ubiattach \
		$(TARGET_DIR)/usr/sbin/ubidetach \
		$(TARGET_DIR)/usr/sbin/readverity \
		$(TARGET_DIR)/sbin/switch_root \
		$(HNVRAM_BIN) \
		$(SGDISK_BIN) \
		$(LOSETUP_BIN) \
		$(DMSETUP_BIN) \
		$(@D)/fs/bin/

	# driver firmware and modules
	ln -f	fs/skeleton/sbin/hotplug $(@D)/fs/sbin/
	ln -f	fs/skeleton/etc/utils.sh $(@D)/fs/etc/
	if [ "$(BR2_PACKAGE_MINDSPEED_DRIVERS)" = "y" ]; then \
		mkdir -p $(@D)/fs/lib/modules $(@D)/fs/lib/firmware && \
		ln -f	$(TARGET_DIR)/lib/modules/*/extra/pfe.ko \
			$(@D)/fs/lib/modules/ && \
		ln -f	$(TARGET_DIR)/lib/firmware/*c2000*.elf \
			$(@D)/fs/lib/firmware/; \
	fi
	if [ "$(BR2_PACKAGE_SIMPLERAMFS_FIRMWARE)" = "y" ]; then \
		mkdir -p $(@D)/fs/lib/firmware; \
		tmp=$(BR2_PACKAGE_SIMPLERAMFS_FIRMWARE_FILENAMES); \
		for d in $$tmp; do \
		  for dd in $(@D)/$$d; do \
		    dir=$$(dirname "$(@D)/fs/lib/firmware/$$d"); \
		    mkdir -p "$$dir"; \
		    ln -f $(TARGET_DIR)/lib/firmware/$$d $$dir; \
		  done; \
		done; \
	fi

	# strip all the binaries
	$(STRIPCMD) $(@D)/fs/bin/*

	# except this one
	ln -f	fs/skeleton/bin/register_experiment $(@D)/fs/bin/

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

	# strip all the libraries
	# TODO(mka): the libraries should be already stripped, but for some reason
	# sometimes (at least) libstdc++ is unstripped
	$(STRIPCMD) $(@D)/fs/lib/*.so*
endef

define SIMPLERAMFS_INSTALL_IMAGES_CMDS
	(cd $(@D)/fs && \
	 ((find; echo /dev/console; echo /dev/kmsg) | cpio -oH newc)) \
		>$(BINARIES_DIR)/simpleramfs.cpio.new
	mv $(BINARIES_DIR)/simpleramfs.cpio.new \
	   $(BINARIES_DIR)/simpleramfs.cpio
endef

$(eval $(call GENTARGETS))
