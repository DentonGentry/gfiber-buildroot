################################################################################
#
# micropython-lib
#
################################################################################

MICROPYTHON_LIB_VERSION = v1.8.2
MICROPYTHON_LIB_SITE = https://github.com/micropython/micropython-lib/archive/
MICROPYTHON_LIB_SOURCE = $(MICROPYTHON_LIB_VERSION).tar.gz
MICROPYTHON_LIB_LICENSE = Python software foundation license v2 (some modules), MIT (everything else)
MICROPYTHON_LIB_LICENSE_FILES = LICENSE

define MICROPYTHON_LIB_INSTALL_TARGET_CMDS
    $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
        PREFIX=$(TARGET_DIR)/usr/lib/micropython \
        install
endef

$(eval $(call GENTARGETS))
