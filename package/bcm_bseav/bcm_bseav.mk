BCM_BSEAV_SITE=repo://vendor/broadcom/BSEAV
BCM_BSEAV_DEPENDENCIES=linux openssl
BCM_BSEAV_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/BSEAV

include package/bcm_common/bcm_common.mk

$(eval $(call GENTARGETS,package,bcm_bseav))
