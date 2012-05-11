#############################################################
#
# py-curl
#
#############################################################
http://pycurl.sourceforge.net/download/pycurl-7.19.0.tar.gz
PY_CURL_VERSION=7.19.0
PY_CURL_SITE=http://pycurl.sourceforge.net/download/
PY_CURL_SOURCE=pycurl-$(PY_CURL_VERSION).tar.gz

PY_CURL_DEPENDENCIES=python libcurl

define PY_CURL_BUILD_CMDS
	$(MAKE) -C $(@D)/src CC="$(TARGET_CC)" PYINCLUDE=${STAGING_DIR}/usr/include/python2.7 all
endef

define PY_CURL_INSTALL_TARGET_CMDS
	cp $(@D)/src/pycurl.so $(TARGET_DIR)/usr/lib/python2.7/site-packages/
	cp -r $(@D)/python/curl $(TARGET_DIR)/usr/lib/python2.7/site-packages/
endef

$(eval $(call GENTARGETS))
