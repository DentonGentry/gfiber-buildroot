MV_CUST_VERSION=master
MV_CUST_SITE=git://localhost/vendor-marvell-mv_cust.git
# MV_CUST_DEPENDENCIES=linux

define MV_CUST_BUILD_CMDS
	mkdir -p $(@D)/lib
	$(MAKE) -C $(@D) CROSS_COMPILE=$(TARGET_CROSS) KDIR=$(LINUX_DIR) 
endef

define MV_CUST_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/modules/mv_cust
	$(INSTALL) -D -m 0755 $(@D)/lib/mvcust.ko $(TARGET_DIR)/lib/modules/mv_cust/mvcust.ko
endef

$(eval $(call GENTARGETS,package,mv_cust))
