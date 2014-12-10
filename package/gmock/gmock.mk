############################################################
#
# gmock
#
############################################################

GMOCK_SITE = http://googlemock.googlecode.com/svn/trunk
GMOCK_SITE_METHOD = svn
# Release 1.6.0
GMOCK_VERSION = 386

define HOST_GMOCK_BUILD_CMDS
	CC="$(HOSTCC)" CXX="$(HOSTCXX)" CFLAGS="$(HOST_CFLAGS) -fPIC" \
	   CXXFLAGS="$(HOST_CXXFLAGS) -fPIC" LDFLAGS="$(HOST_LDFLAGS) -fPIC" \
	   $(MAKE) -C $(@D)/make
endef

define HOST_GMOCK_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/usr/include
	ln -sf $(@D)/include/gmock $(HOST_DIR)/usr/include/
	$(INSTALL) -D $(@D)/make/gmock_main.a $(HOST_DIR)/usr/lib/libgmock.a
endef

define HOST_GMOCK_UNINSTALL_CMDS
	rm -f $(HOST_DIR)/usr/include/gmock
	rm -f $(HOST_DIR)/usr/lib/libgmock.a
endef

$(eval $(call GENTARGETS,host))
