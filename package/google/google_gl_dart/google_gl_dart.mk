GOOGLE_GL_DART_SITE=repo://vendor/google/gl_dart
GOOGLE_GL_DART_DEPENDENCIES=\
	bcm_rockford \
	google_dart_vm
GOOGLE_GL_DART_INSTALL_STAGING=YES

define GOOGLE_GL_DART_BUILD_CMDS
        $(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D) -f Makefile all
endef

define GOOGLE_GL_DART_INSTALL_STAGING_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D) -f Makefile \
		DESTDIR=$(STAGING_DIR) install
endef

define GOOGLE_GL_DART_INSTALL_TARGET_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D) -f Makefile \
		DESTDIR=$(TARGET_DIR) install
endef

$(eval $(call GENTARGETS))
