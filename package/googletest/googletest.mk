############################################################
#
# gtest / gmock
#
############################################################

GOOGLETEST_VERSION = release-1.8.0
GOOGLETEST_SITE = git://github.com/google/googletest.git
GOOGLETEST_INSTALL_TARGET = YES
GOOGLETEST_INSTALL_STAGING = YES
GOOGLETEST_LICENSE = BSD-3c
GOOGLETEST_LICENSE_FILES = googletest/LICENSE
GOOGLETEST_CONF_OPT = -DBUILD_GTEST=ON

# Note that this install does something sneaky and temporary:
# Older versions of gtest had:
#    libgtest.a - only the testing pieces
#    libgtest_main.a - everything from libgtest.a + main method.
# Newer versions have it split so that libgtest_main.a includes
# only the main method.
# To complicate things:
# Our gtest install formerly copied libgtest_main.a over as libgtest.a.
# And did the same for libgmock_main/libgmock.
# Note: libgmock_main.a still contains the contents of libgmock.
# So: to keep backwards compatibility, we create a new libgtest.a
# which is structured the same as the old libgtest_main.a.
define HOST_GOOGLETEST_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/usr/include
	ln -sf $(@D)/googlemock/include/gmock $(HOST_DIR)/usr/include/
	ln -sf $(@D)/googletest/include/gtest $(HOST_DIR)/usr/include/
	$(INSTALL) -D $(@D)/googlemock/libgmock_main.a $(HOST_DIR)/usr/lib/libgmock.a
	ar -rcT $(HOST_DIR)/usr/lib/libgtest.a $(@D)/googlemock/gtest/libgtest_main.a $(@D)/googlemock/gtest/libgtest.a
	ar -r $(HOST_DIR)/usr/lib/libgtest_main.a
	ar -r $(HOST_DIR)/usr/lib/libgmock_main.a
endef

define HOST_GOOGLETEST_UNINSTALL_CMDS
	rm -f $(HOST_DIR)/usr/include/gmock
	rm -f $(HOST_DIR)/usr/lib/libgmock.a
	rm -f $(HOST_DIR)/usr/include/gtest
	rm -f $(HOST_DIR)/usr/lib/libgtest.a
endef

$(eval $(call CMAKETARGETS,host))

# See convoluted explanation above.
define GOOGLETEST_STAGING_INSTALL_CMDS
	mkdir -p $(STAGING_DIR)/usr/include
	ln -sf $(@D)/googlemock/include/gmock $(STAGING_DIR)/usr/include/
	ln -sf $(@D)/googletest/include/gtest $(STAGING_DIR)/usr/include/
	$(INSTALL) -D $(@D)/googlemock/libgmock_main.a $(STAGING_DIR)/usr/lib/libgmock.a
	ar -rcT $(STAGING_DIR)/usr/lib/libgtest.a $(@D)/googlemock/gtest/libgtest_main.a $(@D)/googlemock/gtest/libgtest.a
	ar -r $(STAGING_DIR)/usr/lib/libgtest_main.a
	ar -r $(STAGING_DIR)/usr/lib/libgmock_main.a
endef

define GOOGLETEST_UNINSTALL_STAGING_CMDS
	rm -f $(STAGING_DIR)/usr/include/gmock
	rm -f $(STAGING_DIR)/usr/lib/libgmock.a
	rm -f $(STAGING_DIR)/usr/include/gtest
	rm -f $(STAGING_DIR)/usr/lib/libgtest.a
endef


$(eval $(call CMAKETARGETS))
