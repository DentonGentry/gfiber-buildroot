GOOGLE_KEYSTORE_CLIENT_SITE=/dev
GOOGLE_KEYSTORE_CLIENT_SOURCE=null
GOOGLE_KEYSTORE_CLIENT_VERSION=HEAD

ifeq ($(BR2_PACKAGE_BRUNO_PROD),y)
GOOGLE_LICENSES_LICTYPE=playready_prod_license
else
GOOGLE_LICENSES_LICTYPE=playready_dev_license
endif

define HOST_GOOGLE_KEYSTORE_CLIENT_EXTRACT_CMDS
	mkdir -p $(@D)
endef

GOOGLE_KEYSTORE_CLIENT_CL=$(subst files/,,$(shell readlink /google/src/head))

define HOST_GOOGLE_KEYSTORE_CLIENT_CONFIGURE_CMDS
	@echo Using P4 CL$(GOOGLE_KEYSTORE_CLIENT_CL)
	rm -f $(@D)/depot
	ln -sf /google/src/files/$(GOOGLE_KEYSTORE_CLIENT_CL)/depot $(@D)/depot
endef

define HOST_GOOGLE_KEYSTORE_CLIENT_BUILD_CMDS
	(cd $(@D)/depot/google3; \
	blaze --host_jvm_args=-Xmx256m build \
		--noshow_progress \
		--forge -- \
		//isp/fiber/drm:drm_keystore_client )
endef

define GOOGLE_KEYSTORE_CLIENT_EXECUTE
	rm -f $(2) && \
	(cd $(HOST_GOOGLE_KEYSTORE_CLIENT_DIR)/depot/google3; \
	blaze --host_jvm_args=-Xmx256m run \
		--noshow_progress -- \
		//isp/fiber/drm:drm_keystore_client \
		--key_type $(1) \
		--output $(2) ) && chmod 0400 $(2)
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
