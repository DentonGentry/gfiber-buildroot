## Cairo patches (move to local.mk in newer revs of buildroot)
ifeq ($(BR2_PACKAGE_BRUNO),y)

ifeq ($(BR2_PACKAGE_DIRECTFB),y)
CAIRO_CONF_ENV += directfb_CFLAGS="-I$(BCM_APPS_DIR)/opensource/directfb/bin/DirectFB-1.4.15_$(BCM_APPS_BUILD_TYPE)_build.97425$(BCHP_VER)/usr/local/include/directfb"
CAIRO_CONF_ENV += directfb_LIBS="-L$(STAGING_DIR)/staging/usr/local/lib -ldirect -ldirectfb -lfusion"

define CAIRO_DIRECTFB_COPY_FILES
	cp $(CAIRO_DIR_PREFIX)/$(RAWNAME)/cairo-directfb/* $(@D)/src
endef

CAIRO_POST_PATCH_HOOKS += CAIRO_DIRECTFB_COPY_FILES
endif

define CAIRO_REMOVE_TRACE
	rm -f $(TARGET_DIR)/usr/bin/cairo-trace
endef

CAIRO_POST_INSTALL_TARGET_HOOKS += CAIRO_REMOVE_TRACE
endif
