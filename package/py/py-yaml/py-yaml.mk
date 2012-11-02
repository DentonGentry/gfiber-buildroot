#############################################################
#
# py-yaml
#
#############################################################
PY_YAML_VERSION=3.10
PY_YAML_SITE=http://pyyaml.org/download/pyyaml
PY_YAML_SOURCE=PyYAML-$(PY_YAML_VERSION).tar.gz

PY_YAML_DEPENDENCIES=python libyaml

$(eval $(call PYTARGETS))
