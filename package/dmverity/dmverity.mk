############################################################
#
# dmverity
#
############################################################

DMVERITY_SITE = http://git.chromium.org/chromiumos/platform/dm-verity.git
DMVERITY_SITE_METHOD = git
DMVERITY_VERSION = release-R19-2046.B
HOST_DMVERITY_DEPENDENCIES = host-gtest host-gmock

define HOST_DMVERITY_CONFIGURE_CMDS
	ln -sf $(@D) $(@D)/../verity
endef

define HOST_DMVERITY_BUILD_CMDS
	cd $(@D) && CC="$(HOSTCC)" CXX="$(HOSTCXX)" AR="$(HOSTAR)" \
		LD="$(HOSTLD)" CFLAGS="$(HOST_CFLAGS) -Wno-sign-compare" \
		CXXFLAGS="$(HOST_CXXFLAGS) -Wno-sign-compare" \
		LDFLAGS="$(HOST_LDFLAGS)" \
		$(MAKE) WITH_CHROME=0 all
endef

define HOST_DMVERITY_INSTALL_CMDS
	$(INSTALL) -D $(@D)/verity $(HOST_DIR)/usr/bin/verity
endef

define HOST_DMVERITY_UNINSTALL_CMDS
	rm -f $(HOST_DIR)/usr/bin/verity
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
