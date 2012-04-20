GOOGLE_SAGESERVER_VERSION = 20120419
GOOGLE_SAGESERVER_SOURCE = sagetv_server-$(GOOGLE_SAGESERVER_VERSION).tar.gz
GOOGLE_SAGESERVER_SITE = http://www.google.com
GOOGLE_SAGESERVER_DEPENDENCIES =

ifeq ($(BR2_PACKAGE_BRUNO_TEST),y)
define GOOGLE_SAGESERVER_INSTALL_TARGET_CMDS
	cp -drpf $(@D)/* $(TARGET_DIR)/app/sage/
	$(INSTALL) -m 0755 -D package/google/sageserver/S95sageserver-test $(TARGET_DIR)/etc/init.d/S95sageserver
endef
else
define GOOGLE_SAGESERVER_INSTALL_TARGET_CMDS
	cp -drpf $(@D)/* $(TARGET_DIR)/app/sage/
	$(INSTALL) -m 0755 -D package/google/sageserver/S95sageserver $(TARGET_DIR)/etc/init.d/S95sageserver
endef
endif

# To prevent trying to download from buildroot.net
ifeq ($(BR2_PACKAGE_GOOGLE_SAGESERVER),y)
BR2_BACKUP_SITE=www.google.com
endif

$(eval $(call GENTARGETS,package/google,google_sageserver))
