#############################################################
#
# py-openssl
#
#############################################################

PY_OPENSSL_VERSION = 0.13
PY_OPENSSL_SOURCE = pyOpenSSL-$(PY_OPENSSL_VERSION).tar.gz
PY_OPENSSL_SITE = http://pypi.python.org/packages/source/p/pyOpenSSL
PY_OPENSSL_DEPENDENCIES = py-setuptools

$(eval $(call PYTARGETS))
