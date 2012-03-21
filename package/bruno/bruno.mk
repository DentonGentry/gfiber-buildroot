# Until we add a proper package
# :TODO: (by kedong, update BR2_GCC_SHARED_LIBGCC when new toolchain is setup)
GOOGLE_JAVA_HOME=/usr/local/buildtools/java/jdk
BRUNO_SITE=repo://vendor/google/platform
BRUNO_DEPENDENCIES=humax_bootloader humax_misc bcm_drivers
BRUNO_INSTALL_STAGING=YES
BRUNO_INSTALL_TARGET=YES

BRUNO_DEFINES=
BRUNO_STAGING_PATH=usr/lib/bruno

ifeq ($(BR2_PACKAGE_BRUNO),y)
BRUNO_DEFINES += -DBRUNO_PLATFORM=1

define BRUNO_BUILD_CMDS_DIAG
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)/bruno/diag
endef

define BRUNO_INSTALL_STAGING_CMDS_PC
	mkdir -p $(STAGING_DIR)/usr/lib/pkgconfig && \
	cp $(@D)/bruno/pkg-config/bruno.pc $(STAGING_DIR)/usr/lib/pkgconfig/bruno.pc && \
	sed -i"" -e "s@CFLAGS@$(BRUNO_DEFINES)@g" $(STAGING_DIR)/usr/lib/pkgconfig/bruno.pc
endef

ifeq ($(BR2_PACKAGE_BRUNO_GFHD100),y)
BRUNO_DEFINES += -DBRUNO_PLATFORM_GFHD100=1

define BRUNO_INSTALL_STAGING_CMDS_CONFIG
	cp $(@D)/bruno/gfhd100/config/lkr.cfg $(STAGING_DIR)/$(BRUNO_STAGING_PATH)/lkr.cfg
	cp $(@D)/bruno/gfhd100/config/kr.cfg $(STAGING_DIR)/$(BRUNO_STAGING_PATH)/kr.cfg
endef

define BRUNO_INSTALL_TARGET_CMDS_REGISTER_CHECK
	mkdir -p $(TARGET_DIR)/home/test/
	cp -rf $(@D)/bruno/registercheck $(TARGET_DIR)/home/test/
endef

define BRUNO_INSTALL_TARGET_CMDS_DIAG
	$(INSTALL) -D -m 0755 $(@D)/bruno/diag/diagd $(TARGET_DIR)/usr/bin/diagd
endef
endif

endif

ifeq ($(BR2_PACKAGE_BRUNO_TEST),y)
define BRUNO_BUILD_CMDS
	$(BRUNO_BUILD_CMDS_DIAG)
endef
endif

define BRUNO_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/$(BRUNO_STAGING_PATH)
	$(BRUNO_INSTALL_STAGING_CMDS_CONFIG)
	$(BRUNO_INSTALL_STAGING_CMDS_PC)
endef

ifeq ($(BR2_PACKAGE_BRUNO_TEST),y)
define BRUNO_INSTALL_TARGET_CMDS_TEST
	$(BRUNO_INSTALL_TARGET_CMDS_SKEL)
	$(BRUNO_INSTALL_TARGET_CMDS_DIAG)
	$(BRUNO_INSTALL_TARGET_CMDS_REGISTER_CHECK)
endef
endif


BUILD_SECS:=$(shell date +%s --utc)
define BRUNO_INSTALL_TARGET_CMDS
	repo --no-pager manifest -r -o $(TARGET_DIR)/etc/repo-buildroot-manifest
	echo -n 0.3.0-$(BUILD_SECS)-$$(sha1sum $(TARGET_DIR)/etc/repo-buildroot-manifest | cut -c1-20) > $(TARGET_DIR)/etc/version
	if [[ "$(BR2_PACKAGE_BRUNO_TEST)" == "y" ]]; then echo -n "-test"  >> $(TARGET_DIR)/etc/version; fi
	if [[ "$(BR2_PACKAGE_BRUNO_DEBUG)" == "y" ]]; then echo -n "-debug" >> $(TARGET_DIR)/etc/version; fi
	cp $(TARGET_DIR)/etc/version $(BINARIES_DIR)/version
	$(BRUNO_INSTALL_TARGET_CMDS_TEST)
endef

$(eval $(call GENTARGETS,package,bruno))
