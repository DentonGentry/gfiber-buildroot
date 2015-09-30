#############################################################
#
# python-serial
#
#############################################################

PYTHON_SERIAL_VERSION = 2.6
PYTHON_SERIAL_SOURCE  = pyserial-$(PYTHON_SERIAL_VERSION).tar.gz
PYTHON_SERIAL_SITE    = http://pypi.python.org/packages/source/p/pyserial/

PYTHON_SERIAL_DEPENDENCIES = python

define PYTHON_SERIAL_BUILD_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python setup.py build)
endef

define PYTHON_SERIAL_INSTALL_TARGET_CMDS
	(cd $(@D); \
     $(TOPDIR)/support/scripts/simple_lock create $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/easy-install.pth && \
	 $(HOST_DIR)/usr/bin/python setup.py install --prefix=$(TARGET_DIR)/usr && \
     $(TOPDIR)/support/scripts/simple_lock remove $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/easy-install.pth)
endef

$(eval $(call GENTARGETS))
