#############################################################
#
# bossa - flash tool for Atmel SAM
#
#############################################################

# https://github.com/shumatech/BOSSA/archive/af5b9baa70de169021458eeea397d3dbd42a1568.zip

BOSSA_VERSION = af5b9baa70de169021458eeea397d3dbd42a1568
BOSSA_SITE = https://github.com/shumatech/BOSSA
BOSSA_SITE_METHOD = git

XVKBD_MAKE_OPT = \
	CC="$(TARGET_CC)" \
	CXX="$(TARGET_CXX)" \
	LD="$(TARGET_CC)" \

define BOSSA_BUILD_CMDS
	$(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) $(XVKBD_MAKE_OPT)
endef

define BOSSA_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/bossac $(TARGET_DIR)/usr/sbin/bossac
endef

$(eval $(call GENTARGETS))
