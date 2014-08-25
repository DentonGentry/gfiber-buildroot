################################################################################
#
# protobuf
#
################################################################################

PROTOBUF_VERSION = 2.4.1
PROTOBUF_SITE = http://protobuf.googlecode.com/files/
PROTOBUF_LICENSE = BSD-3c
PROTOBUF_LICENSE_FILES = COPYING.txt

# N.B. Need to use host protoc during cross compilation.
PROTOBUF_DEPENDENCIES = host-protobuf
PROTOBUF_CONF_OPT = --with-protoc=$(HOST_DIR)/usr/bin/protoc --enable-static

PROTOBUF_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_ZLIB),y)
PROTOBUF_DEPENDENCIES += zlib
endif

define PROTOBUF_REMOVE_PROTOC
	rm -f $(TARGET_DIR)/usr/bin/protoc
endef

PROTOBUF_POST_INSTALL_TARGET_HOOKS += PROTOBUF_REMOVE_PROTOC

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
