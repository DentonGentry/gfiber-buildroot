SAGETV_MINICLIENT_SITE=repo://vendor/sagetv/miniclient
SAGETV_MINICLIENT_DEPENDENCIES=linux bcm_nexus bcm_rockford sagetv_pullreader openssl

include package/bcm_common/bcm_common.mk

define SAGETV_MINICLIENT_BUILD_CMDS
        PULLREADER_PATH=$(STAGING_DIR)/usr/local/ \
        $(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D) -f Makefile.7425
endef

define SAGETV_MINICLIENT_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/miniclient $(TARGET_DIR)/app/client/miniclient
        @if [ ! -f $(TARGET_DIR)/etc/init.d/S99miniclient ]; then \
          $(INSTALL) -m 0755 -D package/sagetv/miniclient/S99miniclient $(TARGET_DIR)/etc/init.d/S99miniclient; \
        fi
endef

$(eval $(call GENTARGETS,package/sagetv,sagetv_miniclient))
