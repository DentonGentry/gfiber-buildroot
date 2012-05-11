define PYTARGETS
define $(call UPPERCASE,$(call pkgname))_BUILD_CMDS
	cd $$(@D); PYTHONPATH=$$(TARGET_PYTHONPATH) $$(HOST_DIR)/usr/bin/python setup.py build
endef
define $(call UPPERCASE,$(call pkgname))_INSTALL_TARGET_CMDS
	cd $$(@D); PYTHONPATH=$$(TARGET_PYTHONPATH) $$(HOST_DIR)/usr/bin/python setup.py install --prefix=$$(TARGET_DIR)/usr
endef
$(eval $(call GENTARGETS))
endef

include package/py/*/*.mk
