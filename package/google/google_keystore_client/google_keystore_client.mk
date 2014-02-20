GOOGLE_KEYSTORE_CLIENT_SITE=file:///dev
GOOGLE_KEYSTORE_CLIENT_SOURCE=null
GOOGLE_KEYSTORE_CLIENT_VERSION=HEAD
LICENSE_STATIC_PATH ?= /usr/local/google/gfiber

define HOST_GOOGLE_KEYSTORE_CLIENT_EXTRACT_CMDS
	mkdir -p $(@D)
endef

# This may be appended to by other packages
GOOGLE_KEYSTORE_CLIENT_NEEDS_KEYS=

GOOGLE_KEYSTORE_CLIENT_MISSING_KEYS=$(shell \
	for key in $(GOOGLE_KEYSTORE_CLIENT_NEEDS_KEYS); do \
		echo "Checking $(LICENSE_STATIC_PATH)/$$key" >&2; \
		[ -r "$(LICENSE_STATIC_PATH)/$$key" ] || echo "$$key"; \
	done \
)


GOOGLE_KEYSTORE_CLIENT_CL=$(subst files/,,$(shell readlink /google/src/head))

define GOOGLE_KEYSTORE_CLIENT_EXTRACT_CMDS
endef

define HOST_GOOGLE_KEYSTORE_CLIENT_CONFIGURE_CMDS
	if [ -n "$(GOOGLE_KEYSTORE_CLIENT_MISSING_KEYS)" ]; then \
		echo Using P4 CL$(GOOGLE_KEYSTORE_CLIENT_CL); \
		rm -f $(@D)/depot; \
		ln -sf /google/src/files/$(GOOGLE_KEYSTORE_CLIENT_CL)/depot \
			$(@D)/depot; \
	else \
		echo "All keys available from $(LICENSE_STATIC_PATH);" \
			"skipping blaze."; \
	fi
endef

define HOST_GOOGLE_KEYSTORE_CLIENT_BUILD_CMDS
	if [ -n "$(GOOGLE_KEYSTORE_CLIENT_MISSING_KEYS)" ]; then \
		cd $(@D)/depot/google3; \
		blaze --batch build \
			--noshow_progress \
			--forge -- \
			//isp/fiber/drm:drm_keystore_client; \
	fi
endef

define GOOGLE_KEYSTORE_CLIENT_EXECUTE
	rm -f $(2); \
	if [ -r "$(LICENSE_STATIC_PATH)/$(1)" ]; then \
		cp "$(LICENSE_STATIC_PATH)/$(1)" $(2); \
	else \
		cd $(HOST_GOOGLE_KEYSTORE_CLIENT_DIR)/depot/google3; \
		blaze --batch run \
			--noshow_progress -- \
			//isp/fiber/drm:drm_keystore_client \
			--key_type $(1) \
			--output $(2); \
	fi; \
	chmod 0400 $(2)
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
