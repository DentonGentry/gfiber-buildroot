BCM_ALSA_SITE=repo://vendor/broadcom/alsa
BCM_ALSA_DEPENDENCIES=alsa-lib alsa-utils bcm_nexus host-pkg-config
BCM_ALSA_INSTALL_STAGING=YES
BCM_ALSA_INSTALL_TARGET=YES

include package/bcm_common/bcm_common.mk

define BCM_ALSA_BUILD_CMDS
        $(BCM_MAKE_ENV) $(MAKE1) $(BCM_MAKEFLAGS) CC="$(TARGET_CC)" -C $(@D)/build all
endef

define BCM_ALSA_INSTALL_STAGING_CMDS
	cp -f $(@D)/src/libasound_module_*.so $(STAGING_DIR)/usr/lib/alsa-lib/
	mkdir -p $(STAGING_DIR)/usr/lib/alsa/ $(STAGING_DIR)/usr/bin/alsa/
	cp -f $(@D)/src/alsa.conf $(STAGING_DIR)/usr/lib/alsa/
	cp -f $(@D)/src/alsa.pa $(STAGING_DIR)/usr/lib/alsa/
	echo "#! /bin/bash" > $(STAGING_DIR)/usr/bin/alsa/start
	export $(BCM_MAKE_ENV); \
	if [ "$${NEXUS_MODE}" == "proxy" ]; then \
		echo "kernel_mode=y" >> ${STAGING_DIR}/usr/bin/alsa/start; \
		echo "user_mode=n" >> ${STAGING_DIR}/usr/bin/alsa/start; \
	else \
		echo "kernel_mode=n" >> ${STAGING_DIR}/usr/bin/alsa/start; \
		echo "user_mode=y" >> ${STAGING_DIR}/usr/bin/alsa/start; \
	fi
	@cat $(@D)/src/start >> $(STAGING_DIR)/usr/bin/alsa/start
	chmod ugo+rwx $(STAGING_DIR)/usr/bin/alsa/start
	cp -f $(@D)/src/libaresmgr.so $(STAGING_DIR)/usr/lib
endef

define BCM_ALSA_INSTALL_TARGET_CMDS
	cp -f $(@D)/src/libasound_module_*.so $(TARGET_DIR)/usr/lib/alsa-lib/
	mkdir -p $(TARGET_DIR)/usr/lib/alsa/ $(TARGET_DIR)/usr/bin/alsa/
	cp -f $(@D)/src/alsa.conf $(TARGET_DIR)/usr/lib/alsa/
	cp -f $(@D)/src/alsa.pa $(TARGET_DIR)/usr/lib/alsa/
	echo "#! /bin/bash" > $(TARGET_DIR)/usr/bin/alsa/start
	export $(BCM_MAKE_ENV); \
	if [ "$${NEXUS_MODE}" == "proxy" ]; then \
		echo "kernel_mode=y" >> ${TARGET_DIR}/usr/bin/alsa/start; \
		echo "user_mode=n" >> ${TARGET_DIR}/usr/bin/alsa/start; \
	else \
		echo "kernel_mode=n" >> ${TARGET_DIR}/usr/bin/alsa/start; \
		echo "user_mode=y" >> ${TARGET_DIR}/usr/bin/alsa/start; \
	fi
	@cat $(@D)/src/start >> $(TARGET_DIR)/usr/bin/alsa/start
	chmod ugo+rwx $(TARGET_DIR)/usr/bin/alsa/start
	cp -f $(@D)/src/libaresmgr.so $(TARGET_DIR)/usr/lib
endef

$(eval $(call GENTARGETS,package,bcm_alsa))
