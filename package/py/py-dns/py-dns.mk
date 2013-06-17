#############################################################
#
# py-dns
#
#############################################################

PY_DNS_VERSION = 1.10.0
PY_DNS_SOURCE  = dnspython-$(PY_DNS_VERSION).tar.gz
PY_DNS_SITE    = http://www.dnspython.org/kits/$(PY_DNS_VERSION)

PY_DNS_DEPENDENCIES = python py-setuptools

$(eval $(call PYTARGETS))
