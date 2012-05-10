GOOGLE_SKELMIR_SITE = repo://vendor/skelmir/vm

define GOOGLE_SKELMIR_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/app/sage/skelmir
	cp -af  $(@D)/Binaries/siege \
		$(@D)/Binaries/Libraries \
		$(@D)/Binaries/mipsel-5k-linux-uclibc \
		$(TARGET_DIR)/app/sage/skelmir/
endef

$(eval $(call GENTARGETS))
