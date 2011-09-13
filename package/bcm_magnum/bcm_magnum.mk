BCM_MAGNUM_SITE=repo://vendor/broadcom/magnum
BCM_MAGNUM_DEPENDENCIES=linux
BCM_MAGNUM_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/magnum

include package/bcm_common/bcm_common.mk

$(eval $(call GENTARGETS,package,bcm_magnum))
