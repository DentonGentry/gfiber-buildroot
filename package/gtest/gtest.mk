############################################################
#
# gtest
#
############################################################

GTEST_SITE = http://googletest.googlecode.com/svn/trunk
GTEST_SITE_METHOD = svn
# Release 1.6.0
GTEST_VERSION = 573

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
