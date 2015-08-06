#############################################################
#
# dash
#
#############################################################

DASH_VERSION = 0.5.7
DASH_SOURCE = dash_$(DASH_VERSION).orig.tar.gz
DASH_SITE = $(BR2_DEBIAN_MIRROR)/debian/pool/main/d/dash
DASH_CONF_OPT:=--disable-static
DASH_PATCH = dash_$(DASH_VERSION)-2.diff.gz

$(call BUILD_AFTER_BUSYBOX,dash)

ifneq (,$(findstring mips,$(ARCH)))
DASH_POST_PATCH_HOOKS += DASH_COPY_MIPS_SIGNAMES_C
endif

define DASH_COPY_MIPS_SIGNAMES_C
	cp $(DASH_DIR_PREFIX)/$(RAWNAME)/mips_signames.c $(@D)/src/signames.c
endef

define DASH_INSTALL_TARGET_CMDS
	cp -a $(@D)/src/dash $(TARGET_DIR)/bin/dash
endef

define DASH_CLEAN_CMDS
	$(MAKE) -C $(@D) clean
	rm -f $(TARGET_DIR)/bin/dash
endef

$(eval $(call AUTOTARGETS))
