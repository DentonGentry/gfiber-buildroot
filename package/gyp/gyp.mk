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
		./setup.py install --prefix=$(HOST_DIR)/usr
endef

$(eval $(call GENTARGETS,host))
