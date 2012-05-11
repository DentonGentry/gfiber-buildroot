#############################################################
#
# py-gflags
#
#############################################################

PY_GFLAGS_VERSION=1.6
PY_GFLAGS_SOURCE = python-gflags-$(PY_GFLAGS_VERSION).tar.gz
PY_GFLAGS_SITE = http://python-gflags.googlecode.com/files/

PY_GFLAGS_DEPENDENCIES=py-setuptools

$(eval $(call PYTARGETS))

