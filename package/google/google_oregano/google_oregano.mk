GOOGLE_OREGANO_SITE=repo://vendor/google/oregano
GOOGLE_OREGANO_DEPENDENCIES=\
	bcm_chromium google_miniclient google_dart_vm

define GOOGLE_OREGANO_BUILD_CMDS
	# Surprise, its just a script that runs in the dartvm
endef

define GOOGLE_OREGANO_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/app/oregano/
	$(INSTALL) -m 0755 -D package/google/google_oregano/S99oregano $(TARGET_DIR)/etc/init.d/S99oregano;
	$(INSTALL) -D -m 0755 package/google/google_oregano/runoregano $(TARGET_DIR)/app/oregano/runoregano
	cp -af $(@D)/* $(TARGET_DIR)/app/oregano/
endef

$(eval $(call GENTARGETS))
