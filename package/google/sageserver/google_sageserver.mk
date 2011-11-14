GOOGLE_SAGESERVER_VERSION = 20111108
GOOGLE_SAGESERVER_SOURCE = sagetv_server-$(GOOGLE_SAGESERVER_VERSION).tar.gz
GOOGLE_SAGESERVER_SITE = http://www.google.com
GOOGLE_SAGESERVER_DEPENDENCIES =

define GOOGLE_SAGESERVER_BUILD_CMDS
        echo Using pre-built SageTV server package
endef

define GOOGLE_SAGESERVER_INSTALL_TARGET_CMDS
        cp -drpf $(@D)/* $(TARGET_DIR)/app/sage/
        @if [ ! -f $(TARGET_DIR)/etc/init.d/S95sageserver ]; then \
          $(INSTALL) -m 0755 -D package/google/sageserver/S95sageserver $(TARGET_DIR)/etc/init.d/S95sageserver; \
        fi
endef

# To prevent trying to download from buildroot.net
ifeq ($(BR2_PACKAGE_GOOGLE_SAGESERVER),y)
BR2_BACKUP_SITE=www.google.com
endif

$(eval $(call GENTARGETS,package/google,google_sageserver))
