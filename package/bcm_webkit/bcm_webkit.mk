#############################################################
#
# Broadcom's webkit instance, using Origyn webbrowser
#
#############################################################

BCM_WEBKIT_SITE=repo://vendor/broadcom/webkit
BCM_WEBKIT_DEPENDENCIES=bcm_bseav bcm_nexus bcm_common bcm_directfb bcm_rockford bcm_alsa
BCM_WEBKIT_DEPENDENCIES+=libpng jpeg zlib freetype openssl expat libcurl libxml2 libxslt fontconfig sqlite pixman cairo
BCM_WEBKIT_POST_EXTRACT_HOOKS=BCM_REMOVE_PATCH_REJECTS
BCM_WEBKIT_INSTALL_STAGING=NO
BCM_WEBKIT_INSTALL_TARGET=YES

define BCM_REMOVE_PATCH_REJECTS
	find $(@D) -name '*.rej' -exec rm \{\} \;
endef

define BCM_WEBKIT_CONFIGURE_CMDS
	$(call BCM_COMMON_USE_BUILD_SYSTEM,$(@D))
	$(RM) -rf $(@D)/opensource/directfb
	ln -sf $(BCM_DIRECTFB_DIR)/opensource/directfb $(@D)/opensource/directfb
endef

define BCM_WEBKIT_BUILD_CMDS
	$(BCM_MAKE_ENV) $(MAKE1) $(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) -C $(@D)/common dlna
	$(BCM_MAKE_ENV) $(MAKE1) MAKE_OPTIONS=-j MULTI_BUILD=y $(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) -C $(@D)/common icu
	$(BCM_MAKE_ENV) $(MAKE1) MAKE_OPTIONS=-j MULTI_BUILD=y $(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) -C $(@D)/common browser
endef

define BCM_WEBKIT_INSTALL_TARGET_CMDS
	$(call BCM_COMMON_BUILD_EXTRACT_TARBALL, $(TARGET_DIR))
	$(RM) -f $(TARGET_DIR)/usr/local/lib/modules/nexus.ko
	ln -s ../../../lib/modules/nexus.ko \
	  $(TARGET_DIR)/usr/local/lib/modules/nexus.ko
endef

$(eval $(call GENTARGETS))
