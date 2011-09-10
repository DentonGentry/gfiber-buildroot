BCM_ROCKFORD_VERSION=master
BCM_ROCKFORD_SITE=repo://vendor/broadcom/rockford
BCM_ROCKFORD_DEPENDENCIES=linux
BCM_ROCKFORD_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/rockford

include package/bcm_common/bcm_common.mk

$(eval $(call GENTARGETS,package,bcm_rockford))
