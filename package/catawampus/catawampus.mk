#############################################################
#
# Catawampus tr-69 agent
#
#############################################################
CATAWAMPUS_SITE=repo://vendor/google/catawampus
CATAWAMPUS_INSTALL_TARGET=YES
CATAWAMPUS_DEPENDENCIES=\
	python \
	py-curl \
	host-py-mox \
	host-python \
	host-py-yaml \
	python-netifaces

# Optional extension modules
ifeq ($(BR2_PACKAGE_GOOGLE_PRISM),y)
CATAWAMPUS_DEPENDENCIES+=google_prism
endif


define CATAWAMPUS_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	CWMPD_EXT_DIR=$(TARGET_DIR)/usr/catawampus/ext \
	$(MAKE) -C $(@D)
endef

define CATAWAMPUS_INSTALL_TARGET_CMDS
	DSTDIR=$(TARGET_DIR)/usr/catawampus/ \
	DSTBINDIR=$(TARGET_DIR)/usr/bin/ \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	HOSTPYTHONPATH=$(HOST_PYTHONPATH) \
	TARGETPYTHONPATH=$(TARGET_PYTHONPATH) \
	HOSTDIR=$(HOST_DIR) \
	DESTDIR=$(TARGET_DIR) \
		   $(MAKE) -C $(@D) install

	# Remove installed *.py files since *.pyc files are available
	find $(TARGET_DIR)/usr/catawampus/ -type f -name *.py | \
	while read i; do \
		rm -f $$i; \
	done

	find $(TARGET_DIR)/usr/catawampus/ -type f -name *_test.pyc | \
	while read i; do \
		rm -f $$i; \
	done;

	$(INSTALL) -m 0755 -D package/catawampus/S85catawampus \
		$(TARGET_DIR)/etc/init.d/S85catawampus
endef

define CATAWAMPUS_TEST_CMDS
	PYTHONPATH=$(HOST_PYTHONPATH) \
	PYTHON=$(HOST_DIR)/usr/bin/python \
	CWMPD_EXT_DIR=$(TARGET_DIR)/usr/catawampus/ext \
	$(MAKE) -C $(@D) test
endef

$(eval $(call GENTARGETS))
