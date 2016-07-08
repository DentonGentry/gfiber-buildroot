#############################################################
#
# libcurl
#
#############################################################

LIBCURL_VERSION = 7.46.0
LIBCURL_SOURCE = curl-$(LIBCURL_VERSION).tar.bz2
LIBCURL_SITE = http://curl.haxx.se/download/
LIBCURL_INSTALL_STAGING = YES
LIBCURL_CONF_OPT = --disable-verbose --disable-manual --enable-hidden-symbols

ifeq ($(BR2_PACKAGE_OPENSSL),y)
LIBCURL_DEPENDENCIES += openssl
LIBCURL_CONF_ENV += ac_cv_lib_crypto_CRYPTO_lock=yes
# configure adds the cross openssl dir to LD_LIBRARY_PATH which screws up
# native stuff during the rest of configure when target == host.
# Fix it by setting LD_LIBRARY_PATH to something sensible so those libs
# are found first.
LIBCURL_CONF_ENV += LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:/lib:/usr/lib
LIBCURL_CONF_OPT += --with-ssl=$(STAGING_DIR)/usr --with-random=/dev/urandom \
	--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt
else
LIBCURL_CONF_OPT += --without-ssl
endif

ifeq ($(BR2_INET_IPV6),y)
LIBCURL_CONF_OPT += --enable-ipv6
endif

ifeq ($(BR2_PACKAGE_LIBCARES),y)
LIBCURL_DEPENDENCIES += libcares
LIBCURL_CONF_OPT += --enable-ares
endif

define LIBCURL_TARGET_CLEANUP
	rm -rf $(TARGET_DIR)/usr/bin/curl-config \
	       $(if $(BR2_PACKAGE_CURL),,$(TARGET_DIR)/usr/bin/curl)
endef

LIBCURL_POST_INSTALL_TARGET_HOOKS += LIBCURL_TARGET_CLEANUP

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))

curl: libcurl
curl-clean: libcurl-clean
curl-dirclean: libcurl-dirclean
curl-source: libcurl-source
