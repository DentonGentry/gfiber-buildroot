#
# Macro that builds the needed Makefile target to create a root
# filesystem image.
#
# The following variable must be defined before calling this macro
#
#  ROOTFS_$(FSTYPE)_CMD, the command that generates the root
#  filesystem image. A single command is allowed. The filename of the
#  filesystem image that it must generate is $$@.
#
# The following variables can optionaly be defined
#
#  ROOTFS_$(FSTYPE)_DEPENDENCIES, the list of dependencies needed to
#  build the root filesystem (usually host tools)
#
#  ROOTFS_$(FSTYPE)_POST_TARGETS, the list of targets that should be
#  run after running the main filesystem target. This is useful for
#  initramfs, to rebuild the kernel once the initramfs is generated.
#
# In terms of configuration option, this macro assumes that the
# BR2_TARGET_ROOTFS_$(FSTYPE) config option allows to enable/disable
# the generation of a filesystem image of a particular type. If
# configura options BR2_TARGET_ROOTFS_$(FSTYPE)_GZIP,
# BR2_TARGET_ROOTFS_$(FSTYPE)_BZIP2 or
# BR2_TARGET_ROOTFS_$(FSTYPE)_LZMA exist and are enabled, then the
# macro will automatically generate a compressed filesystem image.

FAKEROOT_SCRIPT = $(BUILD_DIR)/_fakeroot.fs
FAKEROOT_STATE = $(BUILD_DIR)/_fakeroot.state
FULL_DEVICE_TABLE = $(BUILD_DIR)/_device_table.txt
ROOTFS_DEVICE_TABLES = $(call qstrip,$(BR2_ROOTFS_DEVICE_TABLE)) \
	$(call qstrip,$(BR2_ROOTFS_STATIC_DEVICE_TABLE))
ROOTFS_TARGETS:=

_rootfs_base: host-fakeroot host-makedevs
	@$(call MESSAGE,"Generating fakeroot in $(TARGET_DIR)")
	chmod -R a+rX $(TARGET_DIR)
	rm -f $(FAKEROOT_SCRIPT)
	touch $(BUILD_DIR)/.fakeroot.00000
	cat $(BUILD_DIR)/.fakeroot* > $(FAKEROOT_SCRIPT)
	echo "chown -R 0:0 $(TARGET_DIR)" >> $(FAKEROOT_SCRIPT)
ifneq ($(ROOTFS_DEVICE_TABLES),)
	cat $(ROOTFS_DEVICE_TABLES) > $(FULL_DEVICE_TABLE)
ifeq ($(BR2_ROOTFS_DEVICE_CREATION_STATIC),y)
	echo -e '$(subst $(sep),\n,$(PACKAGES_DEVICES_TABLE))' >> $(FULL_DEVICE_TABLE)
endif
	echo -e '$(subst $(sep),\n,$(PACKAGES_PERMISSIONS_TABLE))' >> $(FULL_DEVICE_TABLE)
	echo "$(HOST_DIR)/usr/bin/makedevs -d $(FULL_DEVICE_TABLE) $(TARGET_DIR)" >> $(FAKEROOT_SCRIPT)
endif
	chmod a+x $(FAKEROOT_SCRIPT)
	$(HOST_DIR)/usr/bin/fakeroot -s $(FAKEROOT_STATE) -- $(FAKEROOT_SCRIPT)

$(BINARIES_DIR)/rootfs.%.gz: $(BINARIES_DIR)/rootfs.%
	gzip -9 -c $< >$@

$(BINARIES_DIR)/rootfs.%.bz2: $(BINARIES_DIR)/rootfs.%
	bzip2 -9 -c $< >$@

$(BINARIES_DIR)/rootfs.%.lzma: $(BINARIES_DIR)/rootfs.% host-xz
	$(LZMA) -9 -c $< >$@


define ROOTFS_TARGET_INTERNAL

$(BINARIES_DIR)/rootfs.$(1): _rootfs_base $(ROOTFS_$(2)_DEPENDENCIES)
	@$(call MESSAGE,"Generating root filesystem image rootfs.$(1)")
	rm -f $(FAKEROOT_SCRIPT)-$(1)
	echo "$(ROOTFS_$(2)_CMD)" >> $(FAKEROOT_SCRIPT)-$(1)
	chmod a+x $(FAKEROOT_SCRIPT)-$(1)
	$(HOST_DIR)/usr/bin/fakeroot -i $(FAKEROOT_STATE) -- $(FAKEROOT_SCRIPT)-$(1)

rootfs-$(1)-show-depends:
	@echo $(ROOTFS_$(2)_DEPENDENCIES)

rootfs-$(1): $(BINARIES_DIR)/rootfs.$(1)
	[ -z "$(ROOTFS_$(2)_POST_TARGETS)" ] || $(MAKE) $(ROOTFS_$(2)_POST_TARGETS)

ifeq ($$(BR2_TARGET_ROOTFS_$(2)),y)
ROOTFS_TARGETS += rootfs-$(1)
endif

ifeq ($$(BR2_TARGET_ROOTFS_$(2)_GZIP),y)
ROOTFS_TARGETS += $(BINARIES_DIR)/rootfs.$(1).gz
endif
ifeq ($$(BR2_TARGET_ROOTFS_$(2)_BZIP2),y)
ROOTFS_TARGETS += $(BINARIES_DIR)/rootfs.$(1).bz2
endif
ifeq ($$(BR2_TARGET_ROOTFS_$(2)_LZMA),y)
ROOTFS_TARGETS += $(BINARIES_DIR)/rootfs.$(1).lzma
endif

endef

define ROOTFS_TARGET
$(call ROOTFS_TARGET_INTERNAL,$(1),$(call UPPERCASE,$(1)))
endef

include fs/*/*.mk

rootfs: $(ROOTFS_TARGETS)
