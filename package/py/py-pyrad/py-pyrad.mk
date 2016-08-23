PY_PYRAD_VERSION = 2.0
PY_PYRAD_SOURCE  = pyrad-$(PY_PYRAD_VERSION).tar.gz
PY_PYRAD_SITE    = http://pypi.python.org/packages/source/p/pyrad
PY_PYRAD_DEPENDENCIES = python python-setuptools

$(eval $(call PYTARGETS))
