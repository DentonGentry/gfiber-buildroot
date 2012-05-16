#############################################################
#
# py-uri-templates
#
#############################################################

PY_URI_TEMPLATES_VERSION = r84
PY_URI_TEMPLATES_SITE = http://uri-templates.googlecode.com/svn/trunk
PY_URI_TEMPLATES_SITE_METHOD=svn
PY_URI_TEMPLATES_SITE_DEPENDENCIES=py-setuptools

define PY_URI_TEMPLATES_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/uritemplate.py $(TARGET_PYTHONPATH)/uritemplate.py
endef

$(eval $(call GENTARGETS))
