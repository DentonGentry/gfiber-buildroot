MV_CUST_VERSION=master
MV_CUST_SITE=repo://vendor/marvell/mv_cust
MV_CUST_DEPENDENCIES=linux

define MV_CUST_BUILD_CMDS
	mkdir -p $(@D)/lib
	$(MAKE) -C $(@D) CROSS_COMPILE=$(TARGET_CROSS) KDIR=$(LINUX_DIR)
endef

define MV_CUST_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0555 $(@D)/lib/mvcust.ko $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extras/mvcust.ko
endef

$(eval $(call GENTARGETS,package,mv_cust))
