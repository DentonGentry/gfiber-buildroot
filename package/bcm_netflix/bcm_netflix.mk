BCM_NETFLIX_SITE=repo://vendor/broadcom/netflix
BCM_NETFLIX_DEPENDENCIES=\
	bcm_bseav bcm_nexus bcm_common bcm_directfb bcm_rockford \
	netflix_nrd \
	google_licenses google_hdcp libmng \
	libpng jpeg zlib freetype openssl expat \
	libcurl libxml2 libxslt fontconfig \
	sqlite pixman cairo google_platform libcares webp

define BCM_NETFLIX_CONFIGURE_CMDS
	$(call BCM_COMMON_USE_BUILD_SYSTEM,$(@D))
	$(RM) -rf $(@D)/opensource/directfb
	ln -sf $(BCM_DIRECTFB_DIR)/opensource/directfb $(@D)/opensource/directfb
	if [[ ! -e $(@D)/thirdparty/netflix/4.0/src/nrd ]] ; then \
		mkdir -p $(@D)/thirdparty/netflix/4.0/src; \
		mv $(NETFLIX_NRD_DIR) $(@D)/thirdparty/netflix/4.0/src/nrd; \
		ln -sf $(@D)/thirdparty/netflix/4.0/src/nrd $(NETFLIX_NRD_DIR); \
	fi
endef

define BCM_NETFLIX_BUILD_CMDS
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	$(BCM_MAKE_ENV) NEXUS=${BCM_NEXUS_DIR} $(MAKE) $(NETFLIX_MAKEFLAGS) \
	APPLIBS_TOP=$(@D) NETFLIX_DIR=$(@D)/thirdparty/netflix/4.0/src/nrd NETFLIX_BUILD=single -C $(@D)/thirdparty/netflix/4.0 all
endef


define BCM_NETFLIX_INSTALL_TARGET_CMDS
	$(call BCM_COMMON_BUILD_EXTRACT_TARBALL, $(TARGET_DIR))
endef

$(eval $(call GENTARGETS))
