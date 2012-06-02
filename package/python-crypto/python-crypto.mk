#############################################################
#
# python-crypto
#
#############################################################

PYTHON_CRYPTO_VERSION = 2.6
PYTHON_CRYPTO_SOURCE  = pycrypto-$(PYTHON_CRYPTO_VERSION).tar.gz
PYTHON_CRYPTO_SITE    = http://pypi.python.org/packages/source/p/pycrypto/

PYTHON_CRYPTO_DEPENDENCIES = python host-python host-distutilscross

define HOST_PYTHON_CRYPTO_BUILD_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python setup.py build)
endef

define PYTHON_CRYPTO_CONFIGURE_CMDS
	(rm -f $(@D)/setup.cfg; cp package/python-crypto/setup.cfg $(@D))
endef

define PYTHON_CRYPTO_BUILD_CMDS
	(cd $(@D); CC="$(TARGET_CROSS)gcc -pthread" \
		CFLAGS="$(TARGET_CFLAGS)" 	\
		LDSHARED="$(TARGET_CC) -pthread -shared" \
		LDFLAGS="$(TARGET_LDFLAGS)" 	\
		$(HOST_DIR)/usr/bin/python setup.py build_ext \
		--include-dirs=$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR))
	(cd $(@D); $(HOST_DIR)/usr/bin/python setup.py build)
endef

define HOST_PYTHON_CRYPTO_INSTALL_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python setup.py install \
		--prefix=$(HOST_DIR)/usr)
endef

define PYTHON_CRYPTO_INSTALL_TARGET_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python setup.py install --prefix=$(TARGET_DIR)/usr)
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
