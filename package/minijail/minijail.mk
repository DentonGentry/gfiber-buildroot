MINIJAIL_SITE=repo://vendor/google/minijail
MINIJAIL_DEPENDENCIES=libcap

define MINIJAIL_BUILD_CMDS
	$(MAKE) -C $(@D) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" OUT="$(@D)/" all
endef

define MINIJAIL_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/minijail0 $(TARGET_DIR)/bin/minijail0
	$(INSTALL) -m 0755 -D $(@D)/libminijail.so $(TARGET_DIR)/lib/libminijail.so
	$(INSTALL) -m 0755 -D $(@D)/libminijailpreload.so $(TARGET_DIR)/lib/libminijailpreload.so
endef

$(eval $(call GENTARGETS))
