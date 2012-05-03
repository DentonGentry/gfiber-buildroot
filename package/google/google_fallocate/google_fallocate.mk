GOOGLE_FALLOCATE_SITE=repo://vendor/opensource/fallocate
GOOGLE_FALLOCATE_DEPENDENCIES=linux
GOOGLE_FALLOCATE_INSTALL_STAGING = YES

define GOOGLE_FALLOCATE_BUILD_CMDS
	TARGET=$(TARGET_CROSS) $(MAKE) -C $(@D)
endef

define GOOGLE_FALLOCATE_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libfallocate.so \
		$(STAGING_DIR)/usr/lib/libfallocate.so
	$(INSTALL) -D -m 0644 $(@D)/fallocate64.h \
		$(STAGING_DIR)/usr/include/fallocate64.h
endef

define GOOGLE_FALLOCATE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libfallocate.so \
		$(TARGET_DIR)/usr/lib/libfallocate.so
endef

$(eval $(call GENTARGETS_NEW))
