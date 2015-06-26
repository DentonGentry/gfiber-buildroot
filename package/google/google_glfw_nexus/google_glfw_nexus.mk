GOOGLE_GLFW_NEXUS_SITE=repo://vendor/google/glfw_nexus
GOOGLE_GLFW_NEXUS_DEPENDENCIES=\
	linux \
	bcm_nexus bcm_rockford \
	google_miniclient google_platform
GOOGLE_GLFW_NEXUS_INSTALL_STAGING=YES

define GOOGLE_GLFW_NEXUS_BUILD_CMDS
        $(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D) -f Makefile all
endef

define GOOGLE_GLFW_NEXUS_INSTALL_STAGING_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D) -f Makefile \
		DESTDIR=$(STAGING_DIR) install
endef

define GOOGLE_GLFW_NEXUS_INSTALL_TARGET_CMDS
	$(BCM_MAKE_ENV) $(MAKE) $(BCM_MAKEFLAGS) -C $(@D) -f Makefile \
		DESTDIR=$(TARGET_DIR) install
endef

$(eval $(call GENTARGETS))
