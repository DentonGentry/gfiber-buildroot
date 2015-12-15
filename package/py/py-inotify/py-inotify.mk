PY_INOTIFY_VERSION = 0.9.6
PY_INOTIFY_SOURCE  = pyinotify-$(PY_INOTIFY_VERSION).tar.gz
PY_INOTIFY_SITE    = http://pypi.python.org/packages/source/p/pyinotify
PY_INOTIFY_DEPENDENCIES = python python-setuptools

$(eval $(call PYTARGETS))
