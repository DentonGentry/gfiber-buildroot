################################################################################
#
# python-pypcap
#
################################################################################

PYTHON_PYPCAP_VERSION = 102
PYTHON_PYPCAP_SITE = https://pypcap.googlecode.com/svn/trunk
PYTHON_PYPCAP_SITE_METHOD = svn
PYTHON_PYPCAP_LICENSE = BSD-3c
PYTHON_PYPCAP_LICENSE_FILES = LICENSE
PYTHON_PYPCAP_SETUP_TYPE = distutils
PYTHON_PYPCAP_DEPENDENCIES = host-python-pyrex libpcap

define PYTHON_PYPCAP_CONFIGURE_CMDS
	$(HOST_DIR)/usr/bin/pyrexc $(@D)/pcap.pyx
	(cd $(@D); \
		$(HOST_DIR)/usr/bin/python setup.py \
		config --with-pcap=$(STAGING_DIR)/usr)
endef

define PYTHON_PYPCAP_BUILD_CMDS
	(cd $(@D); \
		CC="$(TARGET_CC)"		\
		CFLAGS="$(TARGET_CFLAGS)" 	\
		LDSHARED="$(TARGET_CC) -shared" \
		LDFLAGS="$(TARGET_LDFLAGS) -lpcap" 	\
	$(HOST_DIR)/usr/bin/python setup.py build_ext \
	--include-dirs=$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR))
	(cd $(@D); \
		CC="$(TARGET_CC)"		\
		CFLAGS="$(TARGET_CFLAGS)" 	\
		LDSHARED="$(TARGET_CC) -shared" \
		LDFLAGS="$(TARGET_LDFLAGS)" 	\
	$(HOST_DIR)/usr/bin/python setup.py build)
endef

define PYTHON_PYPCAP_INSTALL_TARGET_CMDS
	cp $(@D)/build/lib.*/pcap.so $(TARGET_DIR)/usr/lib/python2.7/site-packages/
endef

$(eval $(call GENTARGETS))
