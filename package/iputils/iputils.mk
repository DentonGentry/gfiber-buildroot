#############################################################
#
# iputils library
#
#############################################################

IPUTILS_VERSION = s20101006
IPUTILS_SOURCE = iputils-$(IPUTILS_VERSION).tar.bz2
IPUTILS_SITE = http://www.skbuff.net/iputils

IPUTILS_DEPENDENCIES = linux

# ping6 needs patch for dn_comp
IPUTILS_CMDS = ping tracepath tracepath6 traceroute6

#IPUTILS_CMDS += arping
#IPUTILS_DEPENDENCIES += libsysfs

IPUTILS_CMDS += ping6
IPUTILS_BUILD_FLAGS = VPATH="$(STAGING_DIR)/usr/lib"

define IPUTILS_BUILD_CMDS
	$(MAKE) $(IPUTILS_BUILD_FLAGS) CC="$(TARGET_CC)" -C $(@D) $(IPUTILS_CMDS)

endef

define IPUTILS_INSTALL_TARGET_CMDS
	for cmd in $(IPUTILS_CMDS); do \
		$(INSTALL) -m 0755 -D $(@D)/$$cmd $(TARGET_DIR)/usr/bin/; \
	done
endef


$(eval $(call GENTARGETS))
