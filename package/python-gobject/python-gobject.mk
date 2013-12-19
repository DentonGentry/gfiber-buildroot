#############################################################
#
# python-gobject
#
#############################################################
PYTHON_GOBJECT_MAJOR_VERSION = 2.28
PYTHON_GOBJECT_MINOR_VERSION = 6
PYTHON_GOBJECT_VERSION = $(PYTHON_GOBJECT_MAJOR_VERSION).$(PYTHON_GOBJECT_MINOR_VERSION)
PYTHON_GOBJECT_SOURCE = pygobject-$(PYTHON_GOBJECT_VERSION).tar.bz2
PYTHON_GOBJECT_SITE = http://ftp.gnome.org/pub/GNOME/sources/pygobject/$(PYTHON_GOBJECT_MAJOR_VERSION)/
PYTHON_GOBJECT_INSTALL_STAGING = YES
PYTHON_GOBJECT_INSTALL_TARGET = YES

PYTHON_GOBJECT_CONF_ENV = am_cv_pathless_PYTHON=python \
		ac_cv_path_PYTHON=$(HOST_DIR)/usr/bin/python \
		am_cv_python_version=$(PYTHON_VERSION) \
		am_cv_python_platform=linux2 \
		am_cv_python_pythondir=/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages \
		am_cv_python_pyexecdir=/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages \
		am_cv_python_includes=-I$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR)

PYTHON_GOBJECT_CONF_OPT = --disable-docs \
		--disable-introspection \
		--disable-silent-rules \
		--enable-thread \
		--with-ffi

PYTHON_GOBJECT_DEPENDENCIES = python libglib2

$(eval $(call AUTOTARGETS))
