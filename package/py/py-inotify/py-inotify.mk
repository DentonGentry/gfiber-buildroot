PY_INOTIFY_VERSION = 0.2.4
PY_INOTIFY_SOURCE  = inotify-$(PY_INOTIFY_VERSION).tar.gz
PY_INOTIFY_SITE    = http://pypi.python.org/packages/source/i/inotify
PY_INOTIFY_DEPENDENCIES = python python-setuptools

$(eval $(call PYTARGETS))
