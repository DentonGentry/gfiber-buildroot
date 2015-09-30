#############################################################
#
# python-setuptools
#
#############################################################

PYTHON_SETUPTOOLS_VERSION = 0.7.2
PYTHON_SETUPTOOLS_SOURCE  = setuptools-$(PYTHON_SETUPTOOLS_VERSION).tar.gz
PYTHON_SETUPTOOLS_SITE    = http://pypi.python.org/packages/source/s/setuptools
PYTHON_SETUPTOOLS_DEPENDENCIES = python

define HOST_PYTHON_SETUPTOOLS_BUILD_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python setup.py build)
endef

define PYTHON_SETUPTOOLS_BUILD_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python setup.py build)
endef

define HOST_PYTHON_SETUPTOOLS_INSTALL_CMDS
	cd $(@D) && \
		$(TOPDIR)/support/scripts/simple_lock create $(HOST_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/easy-install.pth && \
		PYTHONPATH="$(HOST_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages" \
		$(HOST_DIR)/usr/bin/python setup.py install --prefix=$(HOST_DIR)/usr && \
		$(TOPDIR)/support/scripts/simple_lock remove $(HOST_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/easy-install.pth
endef

define PYTHON_SETUPTOOLS_INSTALL_TARGET_CMDS
	cd $(@D) && \
		$(TOPDIR)/support/scripts/simple_lock create $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/easy-install.pth && \
		PYTHONPATH="$(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages" \
		$(HOST_DIR)/usr/bin/python setup.py install --prefix=$(TARGET_DIR)/usr && \
		$(TOPDIR)/support/scripts/simple_lock remove $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/easy-install.pth
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))

