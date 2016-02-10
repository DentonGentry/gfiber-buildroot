MV_CPSS_SITE=repo://vendor/marvell/cpss
MV_CPSS_DEPENDENCIES=

MV_CPSS_ENV = \
	TARGET_CROSS=$(TARGET_CROSS) \
	STAGING_DIR=$(STAGING_DIR) \
	BR2_JLEVEL=$(BR2_JLEVEL) \

define MV_CPSS_CONFIGURE_CMDS
	$(MV_CPSS_ENV) $(MAKE) -C $(@D) configure
endef

define MV_CPSS_BUILD_CMDS
	$(MV_CPSS_ENV) $(MAKE) -C $(@D) build
endef

define MV_CPSS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/cpss $(TARGET_DIR)/usr/bin/cpss
	mkdir -p $(TARGET_DIR)/usr/lib/cpss/
	cp -R $(@D)/scripts $(TARGET_DIR)/usr/lib/cpss/scripts
endef

$(eval $(call GENTARGETS))
