PY_GUPPY_VERSION = 0.1.10
PY_GUPPY_SOURCE  = guppy-$(PY_GUPPY_VERSION).tar.gz
PY_GUPPY_SITE    = https://pypi.python.org/packages/source/g/guppy
PY_GUPPY_DEPENDENCIES = python python-setuptools

$(eval $(call PYTARGETS))
