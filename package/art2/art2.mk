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

ifeq ($(BR2_PACKAGE_ART2_NART),y)
define ART2_NART_BUILD
	$(TARGET_MAKE_ENV) $(MAKE) \
		-C $(@D)/art2 ART_ROOT=$(@D)/art2 WORKAREA=$(@D)/art2 \
				TOOL_PREFIX=$(TARGET_CROSS) \
		-f makefile.nart all
endef
ART2_POST_BUILD_HOOKS += ART2_NART_BUILD

define ART2_NART_INSTALL
	for i in $(@D)/art2/nartbuild/*.out; do \
		$(INSTALL) -D -m 0755 "$$i" $(TARGET_DIR)/usr/sbin/; \
	done
	for i in $(@D)/art2/nartbuild/*.so; do \
		$(INSTALL) -D -m 0755 "$$i" $(TARGET_DIR)/usr/lib/; \
	done
	for i in $(@D)/art2/BoardData/*.bin; do \
		$(INSTALL) -D -m 0755 "$$i" $(TARGET_DIR)/usr/sbin/; \
	done
	$(INSTALL) -D -m 0755 package/art2/S99art2 $(TARGET_DIR)/etc/init.d/
endef
ART2_POST_INSTALL_TARGET_HOOKS += ART2_NART_INSTALL
endif


# TODO(awdavies) Some of these options might need to be turned off if this is
# going to be used on something other than GFMN100
define ART2_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) \
		SUBDIRS="$(@D)/art2/driver/linux/modules" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) \
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
			-DCFG_64BIT=0 \
			-DAP83 \
			-DWASP \
			-I$(@D)/art2 \
			-I$(@D)/art2/driver/linux/modules/include" \
		-C "$(LINUX_DIR)" \
		modules_install
endef

$(eval $(call GENTARGETS))
