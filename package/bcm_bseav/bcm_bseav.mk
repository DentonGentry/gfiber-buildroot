BCM_BSEAV_SITE=repo://vendor/broadcom/BSEAV
BCM_BSEAV_DEPENDENCIES=linux bcm_nexus
BCM_BSEAV_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/BSEAV

include package/bcm_common/bcm_common.mk

#PATH=/tmp/gerrit-tmp/buildroot/output/host/usr/bin:$(PATH) TOOLCHAIN_LIB_DIR=/tmp/gerrit-tmp/toolchains/bruno/bin/../lib/gcc/mipsel-linux-uclibc/4.5.3/../../../../mipsel-linux-uclibc/lib/libgcc_s.so TOOLCHAIN_DIR=/tmp/gerrit-tmp/buildroot/output/host/usr/bin/ LINUX=$(LINUX_DIR)
define BCM_BSEAV_BUILD_CMDS
	$(MAKE) $(BCM_MAKEFLAGS)  -C $(@D)/app/brutus/build install
endef

define BCM_BSEAV_INSTALL_TARGET_CMDS
#	$(INSTALL) -D -m 0555 $(@D)/BSEAV/bin/bcmdriver.ko $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extras/bcmdriver.ko
#	$(INSTALL) -D -m 0555 $(@D)/BSEAV/bin/nexus.ko $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extras/nexus.ko
	mkdir -p $(TARGET_DIR)/opt/brcm
	$(TAR) -xf $(@D)/bin/refsw*.tgz -C $(TARGET_DIR)/opt/brcm
endef

$(eval $(call GENTARGETS,package,bcm_bseav))
