#############################################################
#
# py-mock
#
#############################################################

PY_MOCK_VERSION = 1.0.1
PY_MOCK_SOURCE = mock-$(PY_MOCK_VERSION).tar.gz
PY_MOCK_SITE = http://www.voidspace.org.uk/python/mock
PY_MOCK_DEPENDENCIES=python

$(eval $(call PYTARGETS))
