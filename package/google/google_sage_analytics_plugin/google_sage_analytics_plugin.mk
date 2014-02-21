#############################################################
#
# sage_analytics_plugin (GFiber Analytics plugin for Sage)
#
#############################################################
GOOGLE_SAGE_ANALYTICS_PLUGIN_VERSION = 2014-02-19-01@61839646
GOOGLE_SAGE_ANALYTICS_PLUGIN_SITE = mpm://fiber/analytics/sage_plugin
GOOGLE_SAGE_ANALYTICS_PLUGIN_BASE_NAME = google_sage_analytics_plugin
GOOGLE_SAGE_ANALYTICS_PLUGIN_SOURCE = analytics-$(GOOGLE_SAGE_ANALYTICS_PLUGIN_VERSION).tar

define GOOGLE_SAGE_ANALYTICS_PLUGIN_INSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/app/sage/gfiber_analytics_sage_plugin_deploy
	mkdir -p $(TARGET_DIR)/app/sage/gfiber_analytics_sage_plugin_deploy
	unzip -qq $(@D)/gfiber_analytics_sage_plugin_deploy.jar -d $(TARGET_DIR)/app/sage/gfiber_analytics_sage_plugin_deploy
	jar cf0 $(TARGET_DIR)/app/sage/gfiber_analytics_sage_plugin_deploy.jar -C $(TARGET_DIR)/app/sage/gfiber_analytics_sage_plugin_deploy .
	rm -rf $(TARGET_DIR)/app/sage/gfiber_analytics_sage_plugin_deploy
	cp -af package/google/google_sage_analytics_plugin/plugin.properties \
		$(TARGET_DIR)/app/sage/SageClient.properties.defaults.analytics
endef

$(eval $(call GENTARGETS))
