QCA95XX_SITE=repo://vendor/qualcomm/drivers
QCA95XX_DEPENDENCIES=linux

define QCA95XX_CLEAN_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CROSS_COMPILE=$(TARGET_CROSS) -C $(@D) clean
endef

define QCA95XX_BUILD_CMDS
	cd $(@D)/qca95xx/build && \
	$(TARGET_MAKE_ENV) $(MAKE1) CROSS_COMPILE=$(TARGET_CROSS) \
		MAKEARCH=make TOPDIR=$(@D)/qca95xx KERNELPATH=$(@D)/../linux-HEAD \
		INSTALL_ROOT=$(@D)/../../target \
		KERNELVER=$(shell cat $(@D)/../linux-HEAD/include/config/kernel.release) \
		BOARD_TYPE=ap143 BUILD_TYPE=jffs2 -f Makefile.board953x \
		enet_build art_mod driver_build cgi busybox_build athr-hostapd \
		acfg_build lzma_build
endef

define QCA95XX_INSTALL_TARGET_CMDS
endef

$(eval $(call GENTARGETS))
