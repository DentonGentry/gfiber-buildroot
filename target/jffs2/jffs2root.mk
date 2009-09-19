#############################################################
#
# Build the jffs2 root filesystem image
#
#############################################################

JFFS2_OPTS := -e $(BR2_TARGET_ROOTFS_JFFS2_EBSIZE)
SUMTOOL_OPTS := $(JFFS2_OPTS)

ifeq ($(BR2_TARGET_ROOTFS_JFFS2_PAD),y)
ifneq ($(strip $(BR2_TARGET_ROOTFS_JFFS2_PADSIZE)),0x0)
JFFS2_OPTS += --pad=$(strip $(BR2_TARGET_ROOTFS_JFFS2_PADSIZE))
else
JFFS2_OPTS += -p
endif
SUMTOOL_OPTS += -p
endif

ifeq ($(BR2_TARGET_ROOTFS_JFFS2_LE),y)
JFFS2_OPTS += -l
SUMTOOL_OPTS += -l
endif

ifeq ($(BR2_TARGET_ROOTFS_JFFS2_BE),y)
JFFS2_OPTS += -b
SUMTOOL_OPTS += -b
endif

JFFS2_OPTS += -s $(BR2_TARGET_ROOTFS_JFFS2_PAGESIZE)
ifeq ($(BR2_TARGET_ROOTFS_JFFS2_NOCLEANMARKER),y)
JFFS2_OPTS += -n
SUMTOOL_OPTS += -n
endif

JFFS2_TARGET := $(call qstrip,$(BR2_TARGET_ROOTFS_JFFS2_OUTPUT))
ifneq ($(TARGET_DEVICE_TABLE),)
JFFS2_OPTS += -D $(TARGET_DEVICE_TABLE)
endif


#
# mtd-host is a dependency which builds a local copy of mkfs.jffs2 if it is needed.
# the actual build is done from package/mtd/mtd.mk and it sets the
# value of MKFS_JFFS2 to either the previously installed copy or the one
# just built.
#
$(JFFS2_TARGET): host-fakeroot makedevs mtd-host
	# Use fakeroot to pretend all target binaries are owned by root
	rm -f $(BUILD_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	touch $(BUILD_DIR)/.fakeroot.00000
	cat $(BUILD_DIR)/.fakeroot* > $(BUILD_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	echo "chown -R 0:0 $(TARGET_DIR)" >> $(BUILD_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
ifneq ($(TARGET_DEVICE_TABLE),)
	# Use fakeroot to pretend to create all needed device nodes
	echo "$(HOST_DIR)/usr/bin/makedevs -d $(TARGET_DEVICE_TABLE) $(TARGET_DIR)" \
		>> $(BUILD_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
endif
	# Use fakeroot so mkfs.jffs2 believes the previous fakery
ifneq ($(BR2_TARGET_ROOTFS_JFFS2_SUMMARY),)
	echo "$(MKFS_JFFS2) $(JFFS2_OPTS) -d $(TARGET_DIR) -o $(JFFS2_TARGET).nosummary && " \
		"$(SUMTOOL) $(SUMTOOL_OPTS) -i $(JFFS2_TARGET).nosummary -o $(JFFS2_TARGET) && " \
		"rm $(JFFS2_TARGET).nosummary" \
		>> $(BUILD_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
else
	echo "$(MKFS_JFFS2) $(JFFS2_OPTS) -d $(TARGET_DIR) -o $(JFFS2_TARGET)" \
		>> $(BUILD_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
endif
	chmod a+x $(BUILD_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	$(HOST_DIR)/usr/bin/fakeroot -- $(BUILD_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	-@rm -f $(BUILD_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	@ls -l $(JFFS2_TARGET)
ifeq ($(BR2_JFFS2_TARGET_SREC),y)
	$(TARGET_CROSS)objcopy -I binary -O srec --adjust-vma 0xa1000000 $(JFFS2_TARGET) $(JFFS2_TARGET).srec
	@ls -l $(JFFS2_TARGET).srec
endif

JFFS2_COPYTO := $(call qstrip,$(BR2_TARGET_ROOTFS_JFFS2_COPYTO))

jffs2root: $(JFFS2_TARGET)
ifneq ($(JFFS2_COPYTO),)
	@cp -f $(JFFS2_TARGET) $(JFFS2_COPYTO)
endif

jffs2root-source: mtd-host-source

jffs2root-clean: mtd-host-clean
	-rm -f $(JFFS2_TARGET)

jffs2root-dirclean: mtd-host-dirclean
	-rm -f $(JFFS2_TARGET)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_TARGET_ROOTFS_JFFS2),y)
TARGETS+=jffs2root
endif
