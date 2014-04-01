GOOGLE_SKELMIR_SITE = repo://vendor/skelmir/vm

ifeq ($(BR2_mipsel),y)
SKELMIR_ARCH=mipsel-5k-linux-uclibc
SKELMIR_BIN=Binaries/siege
SKELMIR_LIBDIR=Binaries/Libraries
else ifeq ($(BR2_arm),y)
SKELMIR_ARCH=arm-v7l-linux-gnueabi
SKELMIR_BIN=bin/siege
SKELMIR_LIBDIR=lib
else
SKELMIR_ARCH=unknown-skelmir-arch
endif

define GOOGLE_SKELMIR_INSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/app/sage/skelmir
	mkdir -p $(TARGET_DIR)/app/sage/skelmir
	cp -af  $(@D)/$(SKELMIR_ARCH)/$(SKELMIR_LIBDIR)/. \
		$(TARGET_DIR)/app/sage/skelmir/lib
	cp -af  $(@D)/zi \
		$(TARGET_DIR)/app/sage/skelmir/lib/zi
	cp -f $(@D)/$(SKELMIR_ARCH)/$(SKELMIR_BIN) \
		$(TARGET_DIR)/app/sage/skelmir/siege
	ln -sf lib $(TARGET_DIR)/app/sage/skelmir/Libraries
endef

$(eval $(call GENTARGETS))
