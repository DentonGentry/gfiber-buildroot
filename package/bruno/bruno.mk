# Until we add a proper java package
# :TODO: (by kedong, update BR2_GCC_SHARED_LIBGCC when new toolchain is setup)
GOOGLE_JAVA_HOME=/usr/local/buildtools/java/jdk

BRUNO_SITE=repo://vendor/google/platform
BRUNO_INSTALL_STAGING=YES
BRUNO_INSTALL_TARGET=YES
BRUNO_INSTALL_IMAGES=YES

BRUNO_DEPENDENCIES=humax_misc
ifneq ($(BR2_PACKAGE_BRUNO_DEBUG)$(BR2_PACKAGE_BRUNO_TEST),)
BRUNO_DEPENDENCIES += bcm_drivers
endif

BRUNO_STAGING_PATH=usr/lib/bruno
BRUNO_DEFINES += -DBRUNO_PLATFORM=1 -DBRUNO_PLATFORM_GFHD100=1

define BRUNO_BUILD_CMDS
	# diag
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)/diag

	# diag lib and utest
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)/diag/lib
	CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(@D)/diag/utest

	# cmds
	CC="$(TARGET_CC) $(TARGET_CFLAGS)" $(MAKE) -C $(@D)/cmds
endef

define BRUNO_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/$(BRUNO_STAGING_PATH)

	mkdir -p $(STAGING_DIR)/usr/lib/pkgconfig && \
	cp $(@D)/pkg-config/bruno.pc \
		$(STAGING_DIR)/usr/lib/pkgconfig/bruno.pc && \
	sed -i"" -e "s@CFLAGS@$(BRUNO_DEFINES)@g" \
		$(STAGING_DIR)/usr/lib/pkgconfig/bruno.pc
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

	#TODO(apenwarr): /user/diag is nonstandard.  Consider /usr/lib/diag.
	mkdir -p $(TARGET_DIR)/user/diag
	$(INSTALL) -D -m 0755 $(@D)/diag/diagd $(TARGET_DIR)/usr/bin/diagd
	$(INSTALL) -D -m 0644 $(@D)/diag/diag_kern_err_msgs.txt $(TARGET_DIR)/user/diag
	$(INSTALL) -D -m 0644 $(@D)/diag/diag_kern_warn_msgs.txt $(TARGET_DIR)/user/diag
	$(INSTALL) -D -m 0644 $(@D)/diag/diag_ref_data.txt $(TARGET_DIR)/user/diag

	$(INSTALL) -D -m 0755 $(@D)/diag/lib/libbrunodiag.so $(TARGET_DIR)/usr/lib/libbrunodiag.so
	$(INSTALL) -D -m 0755 $(@D)/diag/utest/test_diaglib $(TARGET_DIR)/home/test/test_diaglib

	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(@D)/cmds install

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
