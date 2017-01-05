#############################################################
#
# libcurl_32 (For Netflix)
#
#############################################################

LIBCURL_32_VERSION = 7.32.0
LIBCURL_32_SOURCE = curl-$(LIBCURL_32_VERSION).tar.bz2
LIBCURL_32_SITE = http://curl.haxx.se/download/
LIBCURL_32_INSTALL_STAGING = NO
LIBCURL_32_CONF_OPT = --disable-verbose --disable-manual --enable-hidden-symbols \
                      --disable-shared --enable-optimize --disable-debug \
                      --disable-ftp --disable-file --disable-ldap \
                      --disable-ldaps --disable-rtsp --disable-dict \
                      --disable-telnet --disable-tftp --disable-gopher \
                      --disable-pop3 --disable-imap --disable-smtp \
                      --without-libidn

ifeq ($(BR2_PACKAGE_OPENSSL),y)
LIBCURL_32_DEPENDENCIES += openssl
LIBCURL_32_CONF_ENV += ac_cv_lib_crypto_CRYPTO_lock=yes
# configure adds the cross openssl dir to LD_LIBRARY_PATH which screws up
# native stuff during the rest of configure when target == host.
# Fix it by setting LD_LIBRARY_PATH to something sensible so those libs
# are found first.
LIBCURL_32_CONF_ENV += LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:/lib:/usr/lib
LIBCURL_32_CONF_OPT += --with-ssl=$(STAGING_DIR)/usr --with-random=/dev/urandom \
	--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt
else
LIBCURL_32_CONF_OPT += --without-ssl
endif

ifeq ($(BR2_INET_IPV6),y)
LIBCURL_32_CONF_OPT += --enable-ipv6
endif

ifeq ($(BR2_PACKAGE_LIBCARES),y)
LIBCURL_32_DEPENDENCIES += libcares
LIBCURL_32_CONF_OPT += --enable-ares
endif

define LIBCURL_32_INSTALL_TARGET_CMDS
# We don't install this version, it is accessed directly by the Netflix package
endef

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
