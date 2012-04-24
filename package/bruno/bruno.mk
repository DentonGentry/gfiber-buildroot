# Until we add a proper package
# :TODO: (by kedong, update BR2_GCC_SHARED_LIBGCC when new toolchain is setup)
GOOGLE_JAVA_HOME=/usr/local/buildtools/java/jdk
BRUNO_SITE=repo://vendor/google/platform
BRUNO_INSTALL_STAGING=YES
BRUNO_INSTALL_TARGET=YES

BRUNO_DEPENDENCIES=humax_bootloader humax_misc
ifneq ($(BR2_PACKAGE_BRUNO_DEBUG)$(BR2_PACKAGE_BRUNO_TEST),)
BRUNO_DEPENDENCIES += bcm_drivers
endif

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
	$(BRUNO_INSTALL_STAGING_CMDS_PC)
endef

ifeq ($(BR2_PACKAGE_BRUNO_TEST),y)
define BRUNO_INSTALL_TARGET_CMDS_TEST
	$(BRUNO_INSTALL_TARGET_CMDS_SKEL)
	$(BRUNO_INSTALL_TARGET_CMDS_DIAG)
	$(BRUNO_INSTALL_TARGET_CMDS_REGISTER_CHECK)
endef
endif

ifeq ($(BR2_BRUNO_BCHP_VER),"B2")
ifeq ($(BR2_PACKAGE_BRUNO_PROD),y)
# :TODO: (kedong) update this once the signing service is ready.
BRUNO_LOADER = cfe_signed_unlocked.bin
else
BRUNO_LOADER = cfe_signed_unlocked.bin
endif
endif

BUILD_SECS:=$(shell date +%s --utc)
define BRUNO_INSTALL_TARGET_CMDS
	repo --no-pager manifest -r -o $(TARGET_DIR)/etc/manifest
	echo -n 0.5.0-$(BUILD_SECS)-$$(sha1sum $(TARGET_DIR)/etc/manifest | cut -c1-20) > $(TARGET_DIR)/etc/version
	if [[ "$(BR2_PACKAGE_BRUNO_PROD)" != "y" ]]; then echo -n "-dev"  >> $(TARGET_DIR)/etc/version; fi
	if [ ! -z "$(BRUNO_LOADER)" ]; then cp -f $(@D)/bruno/gfhd100/cfe/$(BRUNO_LOADER) $(BINARIES_DIR)/loader.bin; fi
	cp $(TARGET_DIR)/etc/version $(BINARIES_DIR)/version
	$(BRUNO_INSTALL_TARGET_CMDS_TEST)
endef

$(eval $(call GENTARGETS,package,bruno))
