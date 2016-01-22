BCM_BOLT_SIGNING_SITE=repo://vendor/broadcom/bolt
BCM_BOLT_SIGNING_INSTALL_IMAGES=YES

define HOST_BCM_BOLT_SIGNING_INSTALL_CMDS
	cp -prf $(@D)/tool $(HOST_DIR)/usr/bin/boltsigning
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
