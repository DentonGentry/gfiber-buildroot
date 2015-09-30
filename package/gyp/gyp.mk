#############################################################
#
# gyp - Generate Your Projects
#
#############################################################

GYP_VERSION = e1c8fcf74b68637ba632f9fdfa77be088924b850
GYP_SITE = https://chromium.googlesource.com/external/gyp
GYP_SITE_METHOD = git
GYP_DEPENDENCIES = host-python-setuptools

define HOST_GYP_INSTALL_CMDS
	cd $(@D) ; \
		export PATH=$(TARGET_PATH) ; \
		export PYTHONPATH=$(HOST_PYTHONPATH) ; \
        $(TOPDIR)/support/scripts/simple_lock create $(HOST_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/easy-install.pth && \
		./setup.py install --prefix=$(HOST_DIR)/usr && \
        $(TOPDIR)/support/scripts/simple_lock remove $(HOST_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/easy-install.pth
endef

$(eval $(call GENTARGETS,host))
