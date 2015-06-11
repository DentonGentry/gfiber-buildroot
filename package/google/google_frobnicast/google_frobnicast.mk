GOOGLE_FROBNICAST_SITE=repo://vendor/google/frob
GOOGLE_FROBNICAST_INSTALL_TARGET = YES
GOOGLE_FROBNICAST_DEPENDENCIES=\
  python

define GOOGLE_FROBNICAST_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	$(MAKE) -C $(@D)
endef

define GOOGLE_FROBNICAST_INSTALL_TARGET_CMDS
	PYTHON=$(HOST_DIR)/usr/bin/python \
	HOSTPYTHONPATH=$(HOST_PYTHONPATH) \
	HOSTDIR=$(HOST_DIR) \
	DESTDIR=$(TARGET_DIR) \
	$(MAKE) -C $(@D) install
	$(INSTALL) -m 0755 -D package/google/google_frobnicast/S98frobnicast \
		$(TARGET_DIR)/etc/init.d/S98frobnicast
endef

define GOOGLE_FROBNICAST_TEST_CMDS
	PYTHONPATH=$(HOST_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	$(MAKE) -C $(@D) test
endef

$(eval $(call GENTARGETS))
