BCM_NEXUS_VERSION=master
BCM_NEXUS_SITE=repo://vendor/broadcom/nexus
BCM_NEXUS_DEPENDENCIES=linux bcm_magnum bcm_rockford
BCM_NEXUS_CONFIGURE_CMDS=ln -sf $(@D) $(BUILD_DIR)/nexus

include package/bcm_common/bcm_common.mk

$(eval $(call GENTARGETS,package,bcm_nexus))
