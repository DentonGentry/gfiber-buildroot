PY_MONOTIME_VERSION = 1.0
PY_MONOTIME_SOURCE  = Monotime-$(PY_MONOTIME_VERSION).tar.gz
PY_MONOTIME_SITE    = http://pypi.python.org/packages/source/M/Monotime/
PY_MONOTIME_DEPENDENCIES = python python-setuptools

$(eval $(call PYTARGETS))
