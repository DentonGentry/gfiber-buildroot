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
PROTOBUF_CONF_OPT = --with-protoc=$(HOST_DIR)/usr/bin/protoc --enable-static --disable-shared

PROTOBUF_INSTALL_STAGING = NO

ifeq ($(BR2_PACKAGE_ZLIB),y)
PROTOBUF_DEPENDENCIES += zlib
endif

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
