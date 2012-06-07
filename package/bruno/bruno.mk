# Until we add a proper java package
# :TODO: (by kedong, update BR2_GCC_SHARED_LIBGCC when new toolchain is setup)
GOOGLE_JAVA_HOME=/usr/local/buildtools/java/jdk

BRUNO_SITE=repo://vendor/google/platform
BRUNO_INSTALL_STAGING=YES
BRUNO_INSTALL_TARGET=YES
BRUNO_INSTALL_IMAGES=YES

BRUNO_DEPENDENCIES=linux humax_misc bcm_drivers

BRUNO_STAGING_PATH=usr/lib/bruno

define BRUNO_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS) \
	CC="$(TARGET_CC) $(TARGET_CFLAGS)" \
	$(MAKE) -C $(@D)
endef

define BRUNO_TEST_CMDS
	$(MAKE) -C $(@D) test
endef

define BRUNO_INSTALL_STAGING_CMDS
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(@D) install-libs
	mkdir -p $(STAGING_DIR)/$(BRUNO_STAGING_PATH)
endef

ifeq ($(BR2_PACKAGE_BRUNO_PROD),y)
BRUNO_LOADER = cfe_signed_release.bin
BRUNO_LOADER_SIG = cfe_signed_release.sig
else
BRUNO_LOADER = cfe_signed_unlocked.bin
BRUNO_LOADER_SIG = cfe_signed_unlocked.sig
endif

define BRUNO_INSTALL_TARGET_CMDS
	# Generate /etc/manifest and /etc/version
	repo --no-pager manifest -r -o $(TARGET_DIR)/etc/manifest
	#TODO(apenwarr): 'git describe' should use all projects.
	#  Right now it only uses buildroot.  I have a plan for this
	#  involving git submodules, just don't want to change too much
	#  in this code all at once.  This should work for now.
	echo -n $$(git describe --dirty --match 'bruno-*') \
		>$(TARGET_DIR)/etc/version
	if [ "$(BR2_PACKAGE_BRUNO_PROD)" != "y" ]; then \
		(echo -n '-'; \
		 whoami | cut -c1-2) >>$(TARGET_DIR)/etc/version; \
	fi
	cp $(TARGET_DIR)/etc/version $(BINARIES_DIR)/version

	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(@D) install

	# registercheck
	#TODO(apenwarr): do we actually need this for anything?
	mkdir -p $(TARGET_DIR)/home/test/
	cp -rf $(@D)/registercheck $(TARGET_DIR)/home/test/
endef

define BRUNO_INSTALL_IMAGES_CMDS
	if [ -n "$(BRUNO_LOADER)" ]; then \
		cp -f $(@D)/cfe/$(BRUNO_LOADER) \
			$(BINARIES_DIR)/loader.bin; \
		cp -f $(@D)/cfe/$(BRUNO_LOADER_SIG) \
			$(BINARIES_DIR)/loader.sig; \
	fi
endef

$(eval $(call GENTARGETS))
