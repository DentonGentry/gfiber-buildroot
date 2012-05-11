#############################################################
#
# py-httplib2
#
#############################################################

PY_HTTPLIB2_VERSION = 0.7.1
PY_HTTPLIB2_SOURCE = httplib2-$(PY_HTTPLIB2_VERSION).tar.gz
PY_HTTPLIB2_SITE = http://httplib2.googlecode.com/files/
PY_HTTPLIB2_DEPENDENCIES=py-setuptools

$(eval $(call PYTARGETS))
