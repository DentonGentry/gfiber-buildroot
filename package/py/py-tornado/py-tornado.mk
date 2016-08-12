#############################################################
#
# py-tornado
#
#############################################################

PY_TORNADO_VERSION=master
PY_TORNADO_SITE=repo://vendor/opensource/tornado

PY_TORNADO_DEPENDENCIES=python-setuptools py-curl

$(eval $(call PYTARGETS))
