SIMPLERAMFS_SITE=/dev
SIMPLERAMFS_SOURCE=null
SIMPLERAMFS_VERSION=HEAD

SIMPLERAMFS_INSTALL_TARGET=NO
SIMPLERAMFS_INSTALL_STAGING=YES

SIMPLERAMFS_DEPENDENCIES= \
	dash \
	toybox \
	toolbox \
	busybox \
	util-linux \
	mtd

define SIMPLERAMFS_EXTRACT_CMDS
	mkdir -p $(@D)
endef

define SIMPLERAMFS_BUILD_CMDS
	rm -rf $(@D)/fs
	for d in bin lib proc dev sys rootfs mnt tmp; do \
		mkdir -p $(@D)/fs/$$d; \
	done
	
	# the initramfs /init script, executed by the kernel by default
	ln -f fs/simpleramfs/init fs/simpleramfs/mounts $(@D)/fs/
	
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
	
	#TODO(apenwarr): this is the last reference to busybox in simpleramfs.
	# busybox mount is currently required for NFS; toolbox mount doesn't
	# do it right, and util-linux mount requires nfs-tools, which installs
	# extra junk we don't want.
	ln -sf busybox $(@D)/fs/bin/mount
		
	# other required binaries.
	ln -f $(TARGET_DIR)/bin/dash $(@D)/fs/bin/sh
	ln -f 	$(TARGET_DIR)/bin/toolbox \
		$(TARGET_DIR)/bin/toybox \
		$(TARGET_DIR)/bin/busybox \
		$(TARGET_DIR)/usr/sbin/ubiattach \
		$(TARGET_DIR)/usr/sbin/ubidetach \
		$(TARGET_DIR)/sbin/switch_root \
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
		$(TARGET_MAKE_ENV) mipsel-linux-uclibc-readelf -d \
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

# We're not actually copying to staging - we're copying into the kernel
# build directory.  But there's no "INSTALL_*_CMDS" for that, so we use
# staging, which is the closest match philosophically (ie. it's where you
# install stuff that will be used by builds that depend on yours).
define SIMPLERAMFS_INSTALL_STAGING_CMDS
	(cd $(@D)/fs && ((find; echo /dev/console) | cpio -oH newc)) | \
		gzip -c \
		>$(BINARIES_DIR)/simpleramfs.cpio.gz.new
	mv $(BINARIES_DIR)/simpleramfs.cpio.gz.new \
	   $(BINARIES_DIR)/simpleramfs.cpio.gz
	rm -f $(LINUX_DIR)/usr/initramfs_data.cpio*
	cp $(BINARIES_DIR)/simpleramfs.cpio.gz \
	   $(LINUX_DIR)/usr/initramfs_data.cpio
endef

$(eval $(call GENTARGETS,fs,simpleramfs))
