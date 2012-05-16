GOOGLE_LICENSES_SITE=/dev
GOOGLE_LICENSES_SOURCE=null
GOOGLE_LICENSES_VERSION=HEAD

ifeq ($(BR2_PACKAGE_BRUNO_PROD),y)
GOOGLE_LICENSES_LICTYPE=playready_prod_license
else
GOOGLE_LICENSES_LICTYPE=playready_dev_license
endif

define GOOGLE_LICENSES_EXTRACT_CMDS
	mkdir -p $(@D)
endef

GOOGLE_LICENSES_CL=$(subst files/,,$(shell readlink /google/src/head))

define GOOGLE_LICENSES_CONFIGURE_CMDS
	@echo Using P4 CL$(GOOGLE_LICENSES_CL)
	rm -f $(@D)/depot
	ln -sf /google/src/files/$(GOOGLE_LICENSES_CL)/depot $(@D)/depot
endef

define GOOGLE_LICENSES_BUILD_CMDS
	(cd $(@D)/depot/google3; \
	blaze --host_jvm_args=-Xmx256m build \
		--noshow_progress \
		--forge -- \
		//isp/fiber/drm:drm_keystore_client )
endef

define GOOGLE_LICENSES_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/licenses
	(cd $(@D)/depot/google3; \
	blaze --host_jvm_args=-Xmx256m run \
		--noshow_progress -- \
		//isp/fiber/drm:drm_keystore_client \
		--key_type $(GOOGLE_LICENSES_LICTYPE) \
		--output $(TARGET_DIR)/usr/local/licenses/playready.bin )
	chmod 0555 $(TARGET_DIR)/usr/local/licenses/playready.bin
endef

$(eval $(call GENTARGETS))
