#############################################################
#
# py-setuptools
#
#############################################################

PY_SETUPTOOLS_VERSION=0.6c11
PY_SETUPTOOLS_PYVERSION=$(PYTHON_VERSION_MAJOR)
PY_SETUPTOOLS_SITE=http://pypi.python.org/packages/$(PY_SETUPTOOLS_PYVERSION)/s/setuptools/
PY_SETUPTOOLS_SOURCE=setuptools-$(PY_SETUPTOOLS_VERSION)-py$(PY_SETUPTOOLS_PYVERSION).egg

PY_SETUPTOOLS_DEPENDENCIES=python

define PY_SETUPTOOLS_EXTRACT_CMDS
endef

define PY_SETUPTOOLS_INSTALL_TARGET_CMDS
  PYTHONPATH=$(TARGET_PYTHONPATH) PATH=$(HOST_DIR)/usr/bin:$(PATH) bash $(DL_DIR)/$(PY_SETUPTOOLS_SOURCE) --prefix=$(TARGET_DIR)/usr
endef

$(eval $(call GENTARGETS))
