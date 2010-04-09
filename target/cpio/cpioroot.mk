#############################################################
#
# cpio to archive target filesystem
#
#############################################################

CPIO_BASE:=$(IMAGE).cpio

CPIO_ROOTFS_COMPRESSOR:=
CPIO_ROOTFS_COMPRESSOR_EXT:=
CPIO_ROOTFS_COMPRESSOR_PREREQ:=
ifeq ($(BR2_TARGET_ROOTFS_CPIO_GZIP),y)
CPIO_ROOTFS_COMPRESSOR:=gzip -9 -c
CPIO_ROOTFS_COMPRESSOR_EXT:=gz
endif
ifeq ($(BR2_TARGET_ROOTFS_CPIO_BZIP2),y)
CPIO_ROOTFS_COMPRESSOR:=bzip2 -9 -c
CPIO_ROOTFS_COMPRESSOR_EXT:=bz2
endif
ifeq ($(BR2_TARGET_ROOTFS_CPIO_LZMA),y)
CPIO_ROOTFS_COMPRESSOR:=$(LZMA) -9 -c
CPIO_ROOTFS_COMPRESSOR_EXT:=lzma
CPIO_ROOTFS_COMPRESSOR_PREREQ:= host-lzma
endif

ifneq ($(CPIO_ROOTFS_COMPRESSOR),)
CPIO_TARGET := $(CPIO_BASE).$(CPIO_ROOTFS_COMPRESSOR_EXT)
else
CPIO_TARGET := $(CPIO_BASE)
endif

cpioroot-init:
	rm -f $(TARGET_DIR)/init
	ln -s sbin/init $(TARGET_DIR)/init

$(CPIO_BASE): host-fakeroot makedevs cpioroot-init
	# Use fakeroot to pretend all target binaries are owned by root
	rm -f $(BUILD_DIR)/_fakeroot.$(notdir $(CPIO_BASE))
	touch $(BUILD_DIR)/.fakeroot.00000
	cat $(BUILD_DIR)/.fakeroot* > $(BUILD_DIR)/_fakeroot.$(notdir $(CPIO_BASE))
	echo "chown -R 0:0 $(TARGET_DIR)" >> $(BUILD_DIR)/_fakeroot.$(notdir $(CPIO_BASE))
ifneq ($(TARGET_DEVICE_TABLE),)
	# Use fakeroot to pretend to create all needed device nodes
	echo "$(HOST_DIR)/usr/bin/makedevs -d $(TARGET_DEVICE_TABLE) $(TARGET_DIR)" \
		>> $(BUILD_DIR)/_fakeroot.$(notdir $(CPIO_BASE))
endif
	# Use fakeroot so tar believes the previous fakery
	echo "cd $(TARGET_DIR) && find . | cpio --quiet -o -H newc > $(CPIO_BASE)" \
		>> $(BUILD_DIR)/_fakeroot.$(notdir $(CPIO_BASE))
	chmod a+x $(BUILD_DIR)/_fakeroot.$(notdir $(CPIO_BASE))
	$(HOST_DIR)/usr/bin/fakeroot -- $(BUILD_DIR)/_fakeroot.$(notdir $(CPIO_BASE))
	-@rm -f $(BUILD_DIR)/_fakeroot.$(notdir $(CPIO_BASE))

ifneq ($(CPIO_ROOTFS_COMPRESSOR),)
$(CPIO_BASE).$(CPIO_ROOTFS_COMPRESSOR_EXT): $(CPIO_ROOTFS_COMPRESSOR_PREREQ) $(CPIO_BASE)
	$(CPIO_ROOTFS_COMPRESSOR) $(CPIO_BASE) > $(CPIO_TARGET)
endif

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_TARGET_ROOTFS_CPIO),y)
TARGETS+=cpioroot
endif
