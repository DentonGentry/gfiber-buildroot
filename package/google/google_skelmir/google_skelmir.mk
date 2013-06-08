GOOGLE_SKELMIR_SITE = repo://vendor/skelmir/vm

ifeq ($(BR2_mipsel),y)
SKELMIR_ARCH=mipsel-5k-linux-uclibc
else ifeq ($(BR2_arm),y)
SKELMIR_ARCH=arm-v7l-linux-gnueabi
else
SKELMIR_ARCH=unknown-skelmir-arch
endif

define GOOGLE_SKELMIR_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/app/sage/skelmir
	cp -af  $(@D)/Binaries/Libraries \
		$(@D)/Binaries/$(SKELMIR_ARCH) \
		$(TARGET_DIR)/app/sage/skelmir/
	cd $(TARGET_DIR)/app/sage/skelmir && \
	ln -sf  $(SKELMIR_ARCH)/siege* \
		./siege
endef

$(eval $(call GENTARGETS))
