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

define SIMPLERAMFS_EXTRACT_CMDS
	mkdir -p $(@D)
endef

define SIMPLERAMFS_BUILD_CMDS
	rm -rf $(@D)/fs
	for d in bin lib proc dev sys rootfs mnt tmp; do \
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
		$(@D)/fs/bin/

	# strip all the binaries
	$(STRIPCMD) $(@D)/fs/bin/*

	# without ld.so, nothing works
	cp $(TARGET_DIR)/lib/ld-uClibc.so.0 \
		$(@D)/fs/lib/

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
	(cd $(@D)/fs && ((find; echo /dev/console) | cpio -oH newc)) \
		>$(BINARIES_DIR)/simpleramfs.cpio.new
	mv $(BINARIES_DIR)/simpleramfs.cpio.new \
	   $(BINARIES_DIR)/simpleramfs.cpio
endef

$(eval $(call GENTARGETS))
