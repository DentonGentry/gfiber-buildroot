ifeq ($(BR2_PACKAGE_BRUNO),y)

ifeq ($(BR2_PACKAGE_BCM_DIRECTFB),y)
CAIRO_CONF_ENV += directfb_CFLAGS="-I$(BCM_DIRECTFB_DIR)/opensource/directfb/bin/DirectFB-$(DIRECTFB_VERSION)_$(BCM_COMMON_BUILD_TYPE)_build.97425$(BR2_BRUNO_BCHP_VER)/usr/local/include/directfb"
CAIRO_CONF_ENV += directfb_LIBS="-L$(STAGING_DIR)/staging/usr/local/lib -ldirect -ldirectfb -lfusion"
CAIRO_DEPENDENCIES += bcm_directfb

define CAIRO_DIRECTFB_COPY_FILES
	cp $(CAIRO_DIR_PREFIX)/$(RAWNAME)/cairo-directfb/* $(@D)/src
endef

CAIRO_POST_PATCH_HOOKS += CAIRO_DIRECTFB_COPY_FILES
endif # BR2_PACKAGE_BCM_DIRECTFB

define CAIRO_REMOVE_TRACE
	rm -f $(TARGET_DIR)/usr/bin/cairo-trace
endef

CAIRO_POST_INSTALL_TARGET_HOOKS += CAIRO_REMOVE_TRACE


define OPENSSL_BACKPORT_DIRS
	ln -sf $(OPENSSL_DIR) $(BUILD_DIR)/openssl-1.0.0d
endef

OPENSSL_POST_EXTRACT_HOOKS += OPENSSL_BACKPORT_DIRS
endif # BR2_PACKAGE_BRUNO
