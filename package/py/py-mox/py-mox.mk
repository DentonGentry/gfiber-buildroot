#############################################################
#
# py-mox
#
#############################################################

PY_MOX_VERSION = 0.5.3
PY_MOX_SOURCE = mox-$(PY_MOX_VERSION).tar.gz
PY_MOX_SITE = http://pymox.googlecode.com/files/
PY_MOX_DEPENDENCIES=python

$(eval $(call PYTARGETS))
$(eval $(call PYTARGETS,host))
