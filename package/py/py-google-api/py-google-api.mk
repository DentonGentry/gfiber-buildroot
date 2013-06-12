#############################################################
#
# py-google-api
#
#############################################################


PY_GOOGLE_API_VERSION = 1.0beta4
PY_GOOGLE_API_SOURCE = google-api-python-client-$(PY_GOOGLE_API_VERSION).tar.gz
PY_GOOGLE_API_SITE = http://google-api-python-client.googlecode.com/files/

PY_GOOGLE_API_DEPENDENCIES=python python-setuptools py-httplib2 py-uri-templates py-gflags py-oauth2

$(eval $(call PYTARGETS))
