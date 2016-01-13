############################################################
#
# udns
#
############################################################
UDNS_VERSION = 0.4
UDNS_SOURCE = udns_$(UDNS_VERSION).orig.tar.gz
UDNS_SITE = $(BR2_DEBIAN_MIRROR)/debian/pool/main/u/udns/
UDNS_LICENSE = LGPLv2.1+
UDNS_INSTALL_STAGING = YES
UDNS_INSTALL_TARGET = NO

define UDNS_CONFIGURE_CMDS
	cd $(@D); ./configure
endef

define UDNS_BUILD_CMDS
	$(MAKE1) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D) staticlib
endef

define UDNS_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libudns.a $(STAGING_DIR)/usr/lib/libudns.a
	$(INSTALL) -D -m 0644 $(@D)/udns.h $(STAGING_DIR)/usr/include/udns.h
endef

$(eval $(call GENTARGETS))
