ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS),y)
include fs/ginstall/gftv/*.mk
else ifeq ($(BR2_PACKAGE_GOOGLE_WINDCHARGER),y)
include fs/ginstall/gfmn/*.mk
else
include fs/ginstall/gflt/*.mk
endif
