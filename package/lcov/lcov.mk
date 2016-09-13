LCOV_VERSION = 1.12
LCOV_SOURCE = lcov-$(LCOV_VERSION).tar.gz
LCOV_SITE = http://downloads.sourceforge.net/ltp/

define HOST_LCOV_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/lcov $(HOST_DIR)/usr/bin/lcov
	$(INSTALL) -D -m 0755 $(@D)/bin/geninfo $(HOST_DIR)/usr/bin/geninfo
	$(INSTALL) -D -m 0755 $(@D)/bin/genhtml $(HOST_DIR)/usr/bin/genhtml
endef

$(eval $(call GENTARGETS,host))

