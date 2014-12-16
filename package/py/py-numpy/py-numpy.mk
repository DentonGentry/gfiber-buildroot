################################################################################
#
# py-numpy
#
################################################################################

PY_NUMPY_VERSION = 1.8.0
PY_NUMPY_SOURCE = numpy-$(PY_NUMPY_VERSION).tar.gz
PY_NUMPY_SITE = http://downloads.sourceforge.net/numpy
PY_NUMPY_LICENSE = BSD-3c
PY_NUMPY_LICENSE_FILES = LICENSE.txt
PY_NUMPY_DEPENDENCIES = host-python
PY_NUMPY_SETUP_TYPE = distutils

PY_NUMPY_BUILD_OPT = --fcompiler=None

define PY_NUMPY_CONFIGURE_CMDS
	-rm -f $(@D)/site.cfg
	echo "[DEFAULT]" >> $(@D)/site.cfg
	echo "library_dirs = $(STAGING_DIR)/usr/lib" >> $(@D)/site.cfg
	echo "include_dirs = $(STAGING_DIR)/usr/include" >> $(@D)/site.cfg
	echo "libraries =" >> $(@D)/site.cfg
endef

# Some package may include few headers from NumPy, so let's install it
# in the staging area.
PY_NUMPY_INSTALL_STAGING = YES

$(eval $(call PYTARGETS))
