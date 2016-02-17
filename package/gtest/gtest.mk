############################################################
#
# gtest
#
############################################################

GTEST_SITE = http://googletest.googlecode.com/svn/trunk
GTEST_SITE_METHOD = svn
# Release 1.6.0
GTEST_VERSION = 573
GTEST_INSTALL_STAGING = YES

define HOST_GTEST_BUILD_CMDS
	CC="$(HOSTCC)" CXX="$(HOSTCXX)" CFLAGS="$(HOST_CFLAGS) -fPIC" \
	   CXXFLAGS="$(HOST_CXXFLAGS) -fPIC" LDFLAGS="$(HOST_LDFLAGS)" \
	   $(MAKE) -C $(@D)/make
endef

define HOST_GTEST_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/usr/include
	ln -sf $(@D)/include/gtest $(HOST_DIR)/usr/include/
	$(INSTALL) -D $(@D)/make/gtest_main.a $(HOST_DIR)/usr/lib/libgtest.a
endef

define HOST_GTEST_UNINSTALL_CMDS
	rm -f $(HOST_DIR)/usr/include/gtest
	rm -f $(HOST_DIR)/usr/lib/libgtest.a
endef

$(eval $(call GENTARGETS,host))

define GTEST_BUILD_CMDS
	CC="$(TARGET_CC)" CXX="$(TARGET_CXX)" CFLAGS="$(TARGET_CFLAGS) -fPIC" \
	   CXXFLAGS="$(TARGET_CXXFLAGS) -fPIC" LDFLAGS="$(TARGET_LDFLAGS)" \
	   $(MAKE) -C $(@D)/make
endef

define GTEST_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include
	ln -sf $(@D)/include/gtest $(STAGING_DIR)/usr/include/
	$(INSTALL) -D $(@D)/make/gtest_main.a $(STAGING_DIR)/usr/lib/libgtest.a
endef

define GTEST_UNINSTALL_STAGING_CMDS
	rm -f $(STAGING_DIR)/usr/include/gtest
	rm -f $(STAGING_DIR)/usr/lib/libgtest.a
endef

$(eval $(call GENTARGETS))
