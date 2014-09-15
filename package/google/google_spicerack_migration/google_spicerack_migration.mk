#############################################################
#
# spicerack_migration (Plugin for migrating Sage data to Spicerack)
#
#############################################################
GOOGLE_SPICERACK_MIGRATION_SITE = repo://vendor/google/tarballs

define GOOGLE_SPICERACK_MIGRATION_INSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/app/sage/gftv_spicerack_migration_deploy
	mkdir -p $(TARGET_DIR)/app/sage/gftv_spicerack_migration_deploy
	unzip -qq $(@D)/gftv_spicerack_migration_deploy.jar -d $(TARGET_DIR)/app/sage/gftv_spicerack_migration_deploy
	jar cf0 $(TARGET_DIR)/app/sage/gftv_spicerack_migration_deploy.jar -C $(TARGET_DIR)/app/sage/gftv_spicerack_migration_deploy .
	chmod 0644 $(TARGET_DIR)/app/sage/gftv_spicerack_migration_deploy.jar
	rm -rf $(TARGET_DIR)/app/sage/gftv_spicerack_migration_deploy
	$(INSTALL) -m 0644 -D package/google/google_spicerack_migration/plugin.properties \
		$(TARGET_DIR)/app/sage/Sage.properties.defaults.migration
endef

$(eval $(call GENTARGETS))
