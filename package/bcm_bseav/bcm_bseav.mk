BCM_BSEAV_SITE=repo://vendor/broadcom/BSEAV
BCM_BSEAV_DEPENDENCIES=linux openssl
BCM_BSEAV_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/BSEAV


$(eval $(call GENTARGETS))
