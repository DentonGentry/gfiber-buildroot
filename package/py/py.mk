define PYTARGETS
define $(call UPPERCASE,$(2))_BUILD_CMDS
	cd $$(@D); PYTHONPATH=$$(TARGET_PYTHONPATH) $$(HOST_DIR)/usr/bin/python setup.py build
endef
define $(call UPPERCASE,$(2))_INSTALL_TARGET_CMDS
	cd $$(@D); PYTHONPATH=$$(TARGET_PYTHONPATH) $$(HOST_DIR)/usr/bin/python setup.py install --prefix=$$(TARGET_DIR)/usr
endef
$(eval $(call GENTARGETS,$(1),$(2)))
endef

include package/py/*/*.mk
