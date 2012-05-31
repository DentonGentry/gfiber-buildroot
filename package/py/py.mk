define PYTARGETS
PYPKG=$$(call UPPERCASE,$(call pkgname))
define $$(PYPKG)_BUILD_CMDS
	cd $$(@D); PYTHONPATH=$$(TARGET_PYTHONPATH) $$(HOST_DIR)/usr/bin/python setup.py build
endef
define HOST_$(PYPKG)_BUILD_CMDS
	cd $$(@D); PYTHONPATH=$$(HOST_PYTHONPATH) $$(HOST_DIR)/usr/bin/python setup.py build
endef
define $$(PYPKG)_INSTALL_TARGET_CMDS
	cd $$(@D); PYTHONPATH=$$(TARGET_PYTHONPATH) $$(HOST_DIR)/usr/bin/python setup.py install --prefix=$$(TARGET_DIR)/usr
endef
define HOST_$$(PYPKG)_INSTALL_CMDS
	cd $$(@D); PYTHONPATH=$$(HOST_PYTHONPATH) $$(HOST_DIR)/usr/bin/python setup.py install --prefix=$$(HOST_DIR)/usr
endef

$$(PYPKG)_INSTALL_HOST=YES
$$(PYPKG)_INSTALL_TARGET=YES

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
endef

include package/py/*/*.mk
