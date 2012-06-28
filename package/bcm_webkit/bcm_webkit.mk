#############################################################
#
# Broadcom's webkit instance, using Origyn webbrowser
#
#############################################################

BCM_WEBKIT_SITE=repo://vendor/broadcom/webkit
BCM_WEBKIT_DEPENDENCIES=\
	bcm_bseav bcm_nexus bcm_common bcm_directfb bcm_rockford bcm_alsa \
	libpng jpeg zlib freetype openssl expat \
	libcurl libxml2 libxslt fontconfig sqlite pixman cairo
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
	$(BCM_MAKE_ENV) $(MAKE1) $(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) \
		-C $(@D)/common dlna \
		BUILDING_DLNA=1 BUILDING_PLAYBACK_IP=1 \
		BUILDING_REFSW=1 BUILDING_DTCP_IP=1
	$(BCM_MAKE_ENV) $(MAKE1) MAKE_OPTIONS=-j MULTI_BUILD=y \
		$(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) \
		-C $(@D)/common icu \
		BUILDING_ICU=1
	$(BCM_MAKE_ENV) $(MAKE1) MAKE_OPTIONS=-j MULTI_BUILD=y \
		$(BCM_MAKEFLAGS) APPLIBS_TOP=$(@D) \
		-C $(@D)/common browser \
		BUILDING_BROWSER=1
endef

define BCM_WEBKIT_INSTALL_TARGET_CMDS
	$(call BCM_COMMON_BUILD_EXTRACT_TARBALL, $(TARGET_DIR))
endef

# Since the webkit needs dlna, dtcp_ip, etc. to be rebuilt and reinstalled to its
# lib directory. We need to remove the stamp to force the reinstall.
define BCM_WEBKIT_DIRCLEAN_CMDS
	$(RM) $(@D)/common/*.stamp
endef

$(eval $(call GENTARGETS))
