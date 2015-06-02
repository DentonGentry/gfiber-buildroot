##############################
#
# Linux ART2
#
# Currently this only builds the ART2 kernel module, and does not include
# any of the additional tools.
#
###############################

ART2_SITE:=repo://vendor/qualcomm/drivers
ART2_DEPENDENCIES:=linux

define ART2_CONFIGURE_CMDS
endef

define ART2_BUILD_CMDS
# TODO(awdavies) Some of these options might need to be turned off if this is
# going to be used on something other than GFMN100
	$(TARGET_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) \
		SUBDIRS="$(@D)/art2/driver/linux/modules" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) \
			-DUSE_PLATFORM_FRAMEWORK=1 \
			-DCFG_64BIT=0 \
			-DAP83 \
			-DWASP \
			-I$(@D)/art2 \
			-I$(@D)/art2/driver/linux/modules/include" \
		-C "$(LINUX_DIR)" \
		modules
endef

define ART2_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) \
		SUBDIRS="$(@D)/art2/driver/linux/modules" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) \
			-DUSE_PLATFORM_FRAMEWORK=1 \
			-DCFG_64BIT=0 \
			-DAP83 \
			-DWASP \
			-I$(@D)/art2 \
			-I$(@D)/art2/driver/linux/modules/include" \
		-C "$(LINUX_DIR)" \
		modules_install
endef

$(eval $(call GENTARGETS))
