###############################################################################
#
# Linux kernel target
#
###############################################################################
LINUX_VERSION=$(call qstrip,$(BR2_LINUX_KERNEL_VERSION))

# Compute LINUX_SOURCE and LINUX_SITE from the configuration
ifeq ($(LINUX_VERSION),custom)
LINUX_TARBALL = $(call qstrip,$(BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION))
LINUX_SITE = $(dir $(LINUX_TARBALL))
LINUX_SOURCE = $(notdir $(LINUX_TARBALL))
else ifeq ($(BR2_LINUX_KERNEL_CUSTOM_GIT),y)
LINUX_SITE = $(call qstrip,$(BR2_LINUX_KERNEL_CUSTOM_GIT_REPO_URL))
else
LINUX_SOURCE = linux-$(LINUX_VERSION).tar.bz2
# In X.Y.Z, get X and Y. We replace dots and dashes by spaces in order
# to use the $(word) function. We support versions such as 3.1,
# 2.6.32, 2.6.32-rc1, 3.0-rc6, etc.
ifeq ($(findstring x2.6.,x$(LINUX_VERSION)),x2.6.)
LINUX_SITE = $(BR2_KERNEL_MIRROR)/linux/kernel/v2.6/
else
LINUX_SITE = $(BR2_KERNEL_MIRROR)/linux/kernel/v3.x/
endif
# release candidates are in testing/ subdir
ifneq ($(findstring -rc,$(LINUX_VERSION)),)
LINUX_SITE := $(LINUX_SITE)testing/
endif # -rc
endif

LINUX_PATCHES = $(call qstrip,$(BR2_LINUX_KERNEL_PATCH))

LINUX_INSTALL_IMAGES = YES
LINUX_DEPENDENCIES  += host-module-init-tools

ifeq ($(BR2_PACKAGE_SIMPLERAMFS_LINKED_IN),y)
LINUX_DEPENDENCIES += simpleramfs
LINUX_INCLUDES_SIMPLERAMFS = y
endif

LINUX_MAKE_FLAGS = \
	HOSTCC="$(HOSTCC)" \
	HOSTCFLAGS="$(HOSTCFLAGS)" \
	ARCH=$(KERNEL_ARCH) \
	INSTALL_MOD_PATH=$(TARGET_DIR) \
	CROSS_COMPILE="$(CCACHE) $(TARGET_CROSS)" \
	DEPMOD=$(HOST_DIR)/usr/sbin/depmod

# Get the real Linux version, which tells us where kernel modules are
# going to be installed in the target filesystem.
LINUX_VERSION_PROBED = $(shell LOGLINEAR_LEAVE_STDOUT=1 $(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) --no-print-directory -s kernelrelease 2>/dev/null)

ifeq ($(BR2_LINUX_KERNEL_USE_INTREE_DTS),y)
KERNEL_DTS_NAME = $(call qstrip,$(BR2_LINUX_KERNEL_INTREE_DTS_NAME))
else ifeq ($(BR2_LINUX_KERNEL_USE_CUSTOM_DTS),y)
# We keep only the .dts files, so that the user can specify both .dts
# and .dtsi files in BR2_LINUX_KERNEL_CUSTOM_DTS_PATH. Both will be
# copied to arch/<arch>/boot/dts, but only the .dts files will
# actually be generated as .dtb.
KERNEL_DTS_NAME = $(basename $(filter %.dts,$(notdir $(call qstrip,$(BR2_LINUX_KERNEL_CUSTOM_DTS_PATH)))))
endif

ifeq ($(BR2_LINUX_KERNEL_DTS_SUPPORT)$(KERNEL_DTS_NAME),y)
$(error No kernel device tree source specified, check your \
BR2_LINUX_KERNEL_USE_INTREE_DTS / BR2_LINUX_KERNEL_USE_CUSTOM_DTS settings)
endif

ifeq ($(BR2_LINUX_KERNEL_APPENDED_DTB),y)
ifneq ($(words $(KERNEL_DTS_NAME)),1)
$(error Kernel with appended device tree needs exactly one DTS source. \
	Check BR2_LINUX_KERNEL_INTREE_DTS_NAME or BR2_LINUX_KERNEL_CUSTOM_DTS_PATH.)
endif
endif

KERNEL_DTBS = $(addsuffix .dtb,$(KERNEL_DTS_NAME))

ifeq ($(BR2_LINUX_KERNEL_IMAGE_TARGET_CUSTOM),y)
LINUX_IMAGE_NAME=$(call qstrip,$(BR2_LINUX_KERNEL_IMAGE_TARGET_NAME))
else
ifeq ($(BR2_LINUX_KERNEL_UIMAGE),y)
ifeq ($(KERNEL_ARCH),blackfin)
# a uImage, but with a different file name
LINUX_IMAGE_NAME=vmImage
else
LINUX_IMAGE_NAME=uImage
endif
LINUX_DEPENDENCIES+=host-uboot-tools host-lzma
else ifeq ($(BR2_LINUX_KERNEL_BZIMAGE),y)
LINUX_IMAGE_NAME=bzImage
else ifeq ($(BR2_LINUX_KERNEL_ZIMAGE),y)
LINUX_IMAGE_NAME=zImage
else ifeq ($(BR2_LINUX_KERNEL_APPENDED_ZIMAGE),y)
LINUX_IMAGE_NAME = zImage
else ifeq ($(BR2_LINUX_KERNEL_VMLINUX_BIN),y)
LINUX_IMAGE_NAME=vmlinux.bin
else ifeq ($(BR2_LINUX_KERNEL_VMLINUX),y)
LINUX_IMAGE_NAME=vmlinux
else ifeq ($(BR2_LINUX_KERNEL_VMLINUZ),y)
LINUX_IMAGE_NAME=vmlinuz
endif
endif

# Compute the arch path, since i386 and x86_64 are in arch/x86 and not
# in arch/$(KERNEL_ARCH). Even if the kernel creates symbolic links
# for bzImage, arch/i386 and arch/x86_64 do not exist when copying the
# defconfig file.
ifeq ($(KERNEL_ARCH),i386)
KERNEL_ARCH_PATH=$(LINUX_DIR)/arch/x86
else ifeq ($(KERNEL_ARCH),x86_64)
KERNEL_ARCH_PATH=$(LINUX_DIR)/arch/x86
else
KERNEL_ARCH_PATH=$(LINUX_DIR)/arch/$(KERNEL_ARCH)
endif

ifeq ($(BR2_LINUX_KERNEL_VMLINUX),y)
LINUX_IMAGE_PATH=$(LINUX_DIR)/$(LINUX_IMAGE_NAME)
else ifeq ($(BR2_LINUX_KERNEL_VMLINUZ),y)
LINUX_IMAGE_PATH=$(LINUX_DIR)/$(LINUX_IMAGE_NAME)
else
ifeq ($(KERNEL_ARCH),avr32)
LINUX_IMAGE_PATH=$(KERNEL_ARCH_PATH)/boot/images/$(LINUX_IMAGE_NAME)
else
LINUX_IMAGE_PATH=$(KERNEL_ARCH_PATH)/boot/$(LINUX_IMAGE_NAME)
endif
endif # BR2_LINUX_KERNEL_VMLINUX

define LINUX_DOWNLOAD_PATCHES
	$(if $(LINUX_PATCHES),
		@$(call MESSAGE,"Download additional patches"))
	$(foreach patch,$(filter ftp://% http://%,$(LINUX_PATCHES)),\
		$(call DOWNLOAD,$(dir $(patch)),$(notdir $(patch)))$(sep))
endef

LINUX_POST_DOWNLOAD_HOOKS += LINUX_DOWNLOAD_PATCHES

define LINUX_APPLY_PATCHES
	for p in $(LINUX_PATCHES) ; do \
		if echo $$p | grep -q -E "^ftp://|^http://" ; then \
			support/scripts/apply-patches.sh $(@D) $(DL_DIR) `basename $$p` ; \
		elif test -d $$p ; then \
			support/scripts/apply-patches.sh $(@D) $$p linux-\*.patch ; \
		else \
			support/scripts/apply-patches.sh $(@D) `dirname $$p` `basename $$p` ; \
		fi \
	done
endef

LINUX_POST_PATCH_HOOKS += LINUX_APPLY_PATCHES


ifeq ($(BR2_LINUX_KERNEL_USE_DEFCONFIG),y)
KERNEL_SOURCE_CONFIG = $(KERNEL_ARCH_PATH)/configs/$(call qstrip,$(BR2_LINUX_KERNEL_DEFCONFIG))_defconfig
else ifeq ($(BR2_LINUX_KERNEL_USE_CUSTOM_CONFIG),y)
KERNEL_SOURCE_CONFIG = $(BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE)
endif

define LINUX_CONFIGURE_CMDS
	cp $(KERNEL_SOURCE_CONFIG) $(KERNEL_ARCH_PATH)/configs/buildroot_defconfig
	$(TARGET_MAKE_ENV) $(MAKE1) $(LINUX_MAKE_FLAGS) -C $(@D) buildroot_defconfig
	rm $(KERNEL_ARCH_PATH)/configs/buildroot_defconfig
	$(if $(BR2_ARM_EABI),
		$(call KCONFIG_ENABLE_OPT,CONFIG_AEABI,$(@D)/.config),
		$(call KCONFIG_DISABLE_OPT,CONFIG_AEABI,$(@D)/.config))
	# As the kernel gets compiled before root filesystems are
	# built, we create a fake cpio file. It'll be
	# replaced later by the real cpio archive, and the kernel will be
	# rebuilt using the linux26-rebuild-with-initramfs target.
	$(if $(BR2_TARGET_ROOTFS_INITRAMFS),
		touch $(BINARIES_DIR)/rootfs.cpio
		$(call KCONFIG_ENABLE_OPT,CONFIG_BLK_DEV_INITRD,$(@D)/.config)
		$(call KCONFIG_SET_OPT,CONFIG_INITRAMFS_SOURCE,\"$(BINARIES_DIR)/rootfs.cpio\",$(@D)/.config)
		$(call KCONFIG_SET_OPT,CONFIG_INITRAMFS_ROOT_UID,0,$(@D)/.config)
		$(call KCONFIG_SET_OPT,CONFIG_INITRAMFS_ROOT_GID,0,$(@D)/.config)
		$(call KCONFIG_DISABLE_OPT,CONFIG_INITRAMFS_COMPRESSION_NONE,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_INITRAMFS_COMPRESSION_GZIP,$(@D)/.config))
	$(if $(LINUX_INCLUDES_SIMPLERAMFS),
		$(call KCONFIG_SET_OPT,CONFIG_INITRAMFS_SOURCE,\"$(BINARIES_DIR)/simpleramfs.cpio\",$(@D)/.config)
		$(call KCONFIG_SET_OPT,CONFIG_INITRAMFS_ROOT_UID,0,$(@D)/.config)
		$(call KCONFIG_SET_OPT,CONFIG_INITRAMFS_ROOT_GID,0,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_INITRAMFS_COMPRESSION_NONE,$(@D)/.config)
		$(call KCONFIG_DISABLE_OPT,CONFIG_INITRAMFS_COMPRESSION_GZIP,$(@D)/.config))
	$(if $(BR2_TARGET_ROOTFS_RECOVERYFS),
		$(call KCONFIG_ENABLE_OPT,CONFIG_BLK_DEV_RAM,$(@D)/.config)
		$(call KCONFIG_SET_OPT,CONFIG_BLK_DEV_RAM_COUNT,1,$(@D)/.config)
		$(call KCONFIG_SET_OPT,CONFIG_BLK_DEV_RAM_SIZE,65536,$(@D)/.config))
	$(if $(BR2_ROOTFS_DEVICE_CREATION_STATIC),,
		$(call KCONFIG_ENABLE_OPT,CONFIG_DEVTMPFS,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_DEVTMPFS_MOUNT,$(@D)/.config))
	$(if $(BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_MDEV),
		$(call KCONFIG_SET_OPT,CONFIG_UEVENT_HELPER_PATH,\"/sbin/mdev\",$(@D)/.config))
	yes '' | $(TARGET_MAKE_ENV) $(MAKE1) $(LINUX_MAKE_FLAGS) -C $(@D) oldconfig
endef
ifeq ($(BR2_LINUX_KERNEL_DTS_SUPPORT),y)
define LINUX_BUILD_DTB
	$(TARGET_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) -C $(@D) $(KERNEL_DTBS)
endef
define LINUX_INSTALL_DTB
	# dtbs moved from arch/<ARCH>/boot to arch/<ARCH>/boot/dts since 3.8-rc1
	cp $(addprefix \
		$(KERNEL_ARCH_PATH)/boot/$(if $(wildcard \
		$(addprefix $(KERNEL_ARCH_PATH)/boot/dts/,$(KERNEL_DTBS))),dts/),$(KERNEL_DTBS)) \
		$(BINARIES_DIR)/
endef
define LINUX_INSTALL_DTB_TARGET
	# dtbs moved from arch/<ARCH>/boot to arch/<ARCH>/boot/dts since 3.8-rc1
	cp $(addprefix \
		$(KERNEL_ARCH_PATH)/boot/$(if $(wildcard \
		$(addprefix $(KERNEL_ARCH_PATH)/boot/dts/,$(KERNEL_DTBS))),dts/),$(KERNEL_DTBS)) \
		$(TARGET_DIR)/boot/
endef
endif

ifeq ($(BR2_LINUX_KERNEL_APPENDED_DTB),y)
# dtbs moved from arch/$ARCH/boot to arch/$ARCH/boot/dts since 3.8-rc1
define LINUX_APPEND_DTB
	if [ -e $(KERNEL_ARCH_PATH)/boot/$(KERNEL_DTS_NAME).dtb ]; then \
		cat $(KERNEL_ARCH_PATH)/boot/$(KERNEL_DTS_NAME).dtb; \
	else \
		cat $(KERNEL_ARCH_PATH)/boot/dts/$(KERNEL_DTS_NAME).dtb; \
	fi >> $(KERNEL_ARCH_PATH)/boot/zImage
endef
endif

# Compilation. We make sure the kernel gets rebuilt when the
# configuration has changed.
define LINUX_BUILD_CMDS
	$(if $(BR2_LINUX_KERNEL_APPENDED_DTB),
		rm -f $(KERNEL_ARCH_PATH)/boot/zImage)
	$(if $(BR2_LINUX_KERNEL_USE_CUSTOM_DTS),
		cp $(call qstrip,$(BR2_LINUX_KERNEL_CUSTOM_DTS_PATH)) $(KERNEL_ARCH_PATH)/boot/dts/)
	$(TARGET_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) -C $(@D) $(LINUX_IMAGE_NAME)
	@if grep -q "CONFIG_MODULES=y" $(@D)/.config; then 	\
		$(TARGET_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) -C $(@D) modules ;	\
	fi
	$(LINUX_BUILD_DTB)
	$(LINUX_APPEND_DTB)
endef


ifeq ($(BR2_LINUX_KERNEL_INSTALL_TARGET),y)
define LINUX_INSTALL_KERNEL_IMAGE_TO_TARGET
	install -m 0644 -D $(LINUX_IMAGE_PATH) $(TARGET_DIR)/boot/$(LINUX_IMAGE_NAME)
	$(LINUX_INSTALL_DTB_TARGET)
endef
endif

define LINUX_INSTALL_IMAGES_CMDS
	cp $(LINUX_IMAGE_PATH) $(BINARIES_DIR)
	$(LINUX_INSTALL_DTB)
endef

define LINUX_INSTALL_TARGET_CMDS
	$(LINUX_INSTALL_KERNEL_IMAGE_TO_TARGET)
	# Install modules and remove symbolic links pointing to build
	# directories, not relevant on the target
	@if grep -q "CONFIG_MODULES=y" $(@D)/.config; then 	\
		$(TARGET_MAKE_ENV) $(MAKE1) $(LINUX_MAKE_FLAGS) -C $(@D) 		\
			DEPMOD="$(HOST_DIR)/usr/sbin/depmod" modules_install ;		\
		rm -f $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/build ;		\
		rm -f $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/source ;	\
	fi
endef

include linux/linux-ext-*.mk

$(eval $(call GENTARGETS))

linux-menuconfig linux-xconfig linux-gconfig linux-nconfig linux26-menuconfig linux26-xconfig linux26-gconfig linux26-nconfig: dirs $(LINUX_DIR)/.stamp_configured
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) \
		$(subst linux-,,$(subst linux26-,,$@))
	rm -f $(LINUX_DIR)/.stamp_{built,target_installed,images_installed}

linux-savedefconfig linux26-savedefconfig: dirs $(LINUX_DIR)/.stamp_configured
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) \
		$(subst linux-,,$(subst linux26-,,$@))

ifeq ($(BR2_LINUX_KERNEL_USE_CUSTOM_CONFIG),y)
linux-update-config linux26-update-config: $(LINUX_DIR)/.config
	cp -f $(LINUX_DIR)/.config $(BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE)

linux-update-defconfig linux26-update-defconfig: linux-savedefconfig
	cp -f $(LINUX_DIR)/defconfig $(BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE)
else
linux-update-config linux26-update-config: ;
linux-update-defconfig linux26-update-defconfig: ;
endif

# Support for rebuilding the kernel after the cpio archive has
# been generated in $(BINARIES_DIR)/rootfs.cpio.
$(LINUX_DIR)/.stamp_initramfs_rebuilt: $(LINUX_DIR)/.stamp_target_installed $(LINUX_DIR)/.stamp_images_installed $(BINARIES_DIR)/rootfs.cpio
	@$(call MESSAGE,"Rebuilding kernel with initramfs")
	# Build the kernel.
	$(TARGET_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) -C $(@D) $(LINUX_IMAGE_NAME)
	# Copy the kernel image to its final destination
	cp $(LINUX_IMAGE_PATH) $(BINARIES_DIR)
	$(Q)touch $@

# The initramfs building code must make sure this target gets called
# after it generated the initramfs list of files.
linux-rebuild-with-initramfs linux26-rebuild-with-initramfs: $(LINUX_DIR)/.stamp_initramfs_rebuilt

# Checks to give errors that the user can understand
ifeq ($(filter source,$(MAKECMDGOALS)),)
ifeq ($(BR2_LINUX_KERNEL_USE_DEFCONFIG),y)
ifeq ($(call qstrip,$(BR2_LINUX_KERNEL_DEFCONFIG)),)
$(error No kernel defconfig name specified, check your BR2_LINUX_KERNEL_DEFCONFIG setting)
endif
endif

ifeq ($(BR2_LINUX_KERNEL_USE_CUSTOM_CONFIG),y)
ifeq ($(call qstrip,$(BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE)),)
$(error No kernel configuration file specified, check your BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE setting)
endif
endif

define LINUX_DIRCLEAN_CMDS
rm -f $(BINARIES_DIR)/rootfs.initramfs
endef

endif
