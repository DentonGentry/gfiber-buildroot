CRASHME_VERSION = 2.4
CRASHME_SITE = http://ftp.debian.org/debian/pool/main/c/crashme/
CRASHME_SOURCE = crashme_$(CRASHME_VERSION).orig.tar.gz

define CRASHME_BUILD_CMDS
	$(MAKE) -C $(@D) CC="$(TARGET_CC)"
endef

define CRASHME_INSTALL_TARGET_CMDS
	cp $(@D)/crashme $(TARGET_DIR)/usr/bin/
endef

$(eval $(call GENTARGETS))
