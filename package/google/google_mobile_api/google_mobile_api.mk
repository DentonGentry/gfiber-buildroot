#############################################################
#
# mobile_api (GFTV remote API for Android and iOS)
#
#############################################################
GOOGLE_MOBILE_API_VERSION = gfiberapi-33.10
GOOGLE_MOBILE_API_SITE = mpm://fiber/mobile/plugin
GOOGLE_MOBILE_API_BASE_NAME = google_mobile_api
GOOGLE_MOBILE_API_SOURCE = $(GOOGLE_MOBILE_API_VERSION).tar

define GOOGLE_MOBILE_API_INSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/app/sage/gftv_mobile_api_deploy
	mkdir -p $(TARGET_DIR)/app/sage/gftv_mobile_api_deploy
	unzip -qq $(@D)/gftv_mobile_api_deploy.jar -d $(TARGET_DIR)/app/sage/gftv_mobile_api_deploy
	jar cf0 $(TARGET_DIR)/app/sage/gftv_mobile_api_deploy.jar -C $(TARGET_DIR)/app/sage/gftv_mobile_api_deploy .
	chmod 0644 $(TARGET_DIR)/app/sage/gftv_mobile_api_deploy.jar
	rm -rf $(TARGET_DIR)/app/sage/gftv_mobile_api_deploy
	$(INSTALL) -m 0644 -D package/google/google_mobile_api/plugin.properties \
		$(TARGET_DIR)/app/sage/Sage.properties.defaults.mobileapi
endef

$(eval $(call GENTARGETS))
