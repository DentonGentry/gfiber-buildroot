#############################################################
#
# tar to archive target filesystem
#
#############################################################

TAR_OPTS:=$(BR2_TARGET_ROOTFS_TAR_OPTIONS)
TAR_TARGET:=$(IMAGE).tar

TAR_COMPRESSOR:=
TAR_COMPRESSOR_EXT:=.none
ifeq ($(BR2_TARGET_ROOTFS_TAR_GZIP),y)
TAR_COMPRESSOR:=gzip -9 -c
TAR_COMPRESSOR_EXT:=gz
endif
ifeq ($(BR2_TARGET_ROOTFS_TAR_BZIP2),y)
TAR_COMPRESSOR:=bzip2 -9 -c
TAR_COMPRESSOR_EXT:=bz2
endif
ifeq ($(BR2_TARGET_ROOTFS_TAR_LZMA),y)
TAR_COMPRESSOR:=lzma -9 -c
TAR_COMPRESSOR_EXT:=lzma
endif
ROOTFS_TAR_COPYTO:=$(call qstrip,$(BR2_TARGET_ROOTFS_TAR_COPYTO))

tarroot: host-fakeroot makedevs
	# Use fakeroot to pretend all target binaries are owned by root
	rm -f $(BUILD_DIR)/_fakeroot.$(notdir $(TAR_TARGET))
	touch $(BUILD_DIR)/.fakeroot.00000
	cat $(BUILD_DIR)/.fakeroot* > $(BUILD_DIR)/_fakeroot.$(notdir $(TAR_TARGET))
	echo "chown -R 0:0 $(TARGET_DIR)" >> $(BUILD_DIR)/_fakeroot.$(notdir $(TAR_TARGET))
ifneq ($(TARGET_DEVICE_TABLE),)
	# Use fakeroot to pretend to create all needed device nodes
	echo "$(HOST_DIR)/usr/bin/makedevs -d $(TARGET_DEVICE_TABLE) $(TARGET_DIR)" \
		>> $(BUILD_DIR)/_fakeroot.$(notdir $(TAR_TARGET))
endif
	# Use fakeroot so tar believes the previous fakery
	echo "tar -c$(TAR_OPTS)f $(TAR_TARGET) -C $(TARGET_DIR) ." \
		>> $(BUILD_DIR)/_fakeroot.$(notdir $(TAR_TARGET))
	chmod a+x $(BUILD_DIR)/_fakeroot.$(notdir $(TAR_TARGET))
	$(HOST_DIR)/usr/bin/fakeroot -- $(BUILD_DIR)/_fakeroot.$(notdir $(TAR_TARGET))
ifneq ($(TAR_COMPRESSOR),)
	-rm -f $(TAR_TARGET).$()
	PATH="$(STAGING_DIR)/sbin:$(STAGING_DIR)/bin:$(STAGING_DIR)/usr/sbin:$(STAGING_DIR)/usr/bin:$(PATH)" $(TAR_COMPRESSOR) $(TAR_TARGET) > $(TAR_TARGET).$(TAR_COMPRESSOR_EXT)
endif
ifneq ($(ROOTFS_TAR_COPYTO),)
	$(Q)cp -f $(TAR_TARGET) $(ROOTFS_TAR_COPYTO)
endif
	-@rm -f $(BUILD_DIR)/_fakeroot.$(notdir $(TAR_TARGET))

tarroot-source:

tarroot-clean:

tarroot-dirclean:

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_TARGET_ROOTFS_TAR),y)
TARGETS+=tarroot
endif
