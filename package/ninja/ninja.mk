#############################################################
#
# ninja
#
#############################################################
NINJA_VERSION:=1.5.3
NINJA_SOURCE:=v$(NINJA_VERSION).tar.gz
NINJA_SITE:=https://github.com/martine/ninja/archive/

define HOST_NINJA_BUILD_CMDS
	cd $(@D) && $(HOST_DIR)/usr/bin/python ./configure.py --bootstrap
endef

define HOST_NINJA_INSTALL_CMDS
	$(INSTALL) $(@D)/ninja $(HOST_DIR)/usr/bin
endef

$(eval $(call GENTARGETS,host))
