#############################################################
#
# py-pympler
#
#############################################################

PY_PYMPLER_VERSION = 0.4.2
PY_PYMPLER_SOURCE  = Pympler-$(PY_PYMPLER_VERSION).tar.gz
PY_PYMPLER_SITE    = https://pypi.python.org/packages/source/P/Pympler/$(PY_PYMPLER_SOURCE)

PY_PYMPLER_DEPENDENCIES = python py-setuptools

$(eval $(call PYTARGETS))
