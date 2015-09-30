SCONS_VERSION = 2.0.1
SCONS_SOURCE = scons-$(SCONS_VERSION).tar.gz
SCONS_SITE = http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/scons

define HOST_SCONS_BUILD_CMDS
	(cd $(@D); python setup.py build)
endef

define HOST_SCONS_INSTALL_CMDS
	(cd $(@D); \
     $(TOPDIR)/support/scripts/simple_lock create $(HOST_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/easy-install.pth && \
	 python setup.py install --prefix=$(HOST_DIR)/usr && \
     $(TOPDIR)/support/scripts/simple_lock remove $(HOST_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/easy-install.pth)

endef

$(eval $(call GENTARGETS,host))
