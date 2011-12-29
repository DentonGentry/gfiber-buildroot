# Until we add a proper package
# :TODO: (by kedong, update BR2_GCC_SHARED_LIBGCC when new toolchain is setup)
GOOGLE_JAVA_HOME=/usr/local/buildtools/java/jdk
BRUNO_SITE=repo://vendor/google/platform
BRUNO_DEPENDENCIES=humax_bootloader humax_misc bcm_drivers
BRUNO_INSTALL_STAGING=YES
BRUNO_INSTALL_TARGET=NO

BRUNO_DEFINES=
BRUNO_STAGING_PATH=usr/lib/bruno

ifeq ($(BR2_PACKAGE_BRUNO),y)
BRUNO_DEFINES += -DBRUNO_PLATFORM=1

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

endif

endif

define BRUNO_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/$(BRUNO_STAGING_PATH)
	$(BRUNO_INSTALL_STAGING_CMDS_CONFIG)
	$(BRUNO_INSTALL_STAGING_CMDS_PC)
endef

$(eval $(call GENTARGETS,package,bruno))

bruno_%_debug: $(BUILD_DIR)/buildroot-config/conf
	make bruno_$*
	echo 'BR2_PACKAGE_BRUNO_DEBUG=y' >> $(TOPDIR)/.config
	$(COMMON_CONFIG_ENV) $< --defconfig=$(TOPDIR)/.config $(CONFIG_CONFIG_IN)
