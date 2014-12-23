################################################################################
#
# protobuf
#
################################################################################

PROTOBUF_VERSION = 2.5.0
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

define PROTOBUF_REMOVE_EXTRA_STUFF
	rm -f $(TARGET_DIR)/usr/lib/libprotobuf.a
	rm -f $(TARGET_DIR)/usr/lib/libprotoc.a
	rm -f $(TARGET_DIR)/usr/lib/libprotobuf.so*
	rm -f $(TARGET_DIR)/usr/lib/libprotoc.so*
endef
ifeq ($(BR2_PACKAGE_PROTOBUF_ONLY_LITE),y)
PROTOBUF_POST_INSTALL_TARGET_HOOKS += PROTOBUF_REMOVE_EXTRA_STUFF
endif

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
