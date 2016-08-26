################################################################################
#
# protobuf
#
################################################################################

PROTOBUF_VERSION = $(call qstrip,$(BR2_PACKAGE_PROTOBUF_VERSION_VALUE))
PROTOBUF_MAJOR_VERSION = $(firstword $(subst ., ,$(PROTOBUF_VERSION)))
PROTOBUF_SITE = https://github.com/google/protobuf/releases/download/v$(PROTOBUF_VERSION)

ifeq ($(PROTOBUF_MAJOR_VERSION),2)
PROTOBUF_SOURCE = protobuf-$(PROTOBUF_VERSION).tar.gz
else
PROTOBUF_SOURCE = protobuf-cpp-$(PROTOBUF_VERSION).tar.gz
endif
PROTOBUF_LICENSE = BSD-3c
PROTOBUF_LICENSE_FILES = COPYING.txt

# N.B. Need to use host protoc during cross compilation.
PROTOBUF_DEPENDENCIES = host-protobuf
HOST_PROTOBUF_DEPENDENCIES = host-automake
PROTOBUF_CONF_OPT = --with-protoc=$(HOST_DIR)/usr/bin/protoc --enable-static --with-pic

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

ifeq ($(PROTOBUF_MAJOR_VERSION),2)
PROTOBUF_PRE_CONFIGURE_HOOKS += PROTOBUF_EXTRACT_GTEST
HOST_PROTOBUF_PRE_CONFIGURE_HOOKS += PROTOBUF_EXTRACT_GTEST
endif

PROTOBUF_PRE_CONFIGURE_HOOKS += PROTOBUF_AUTOGEN
HOST_PROTOBUF_PRE_CONFIGURE_HOOKS += PROTOBUF_AUTOGEN

define PROTOBUF_EXTRACT_GTEST
	mkdir -p $(@D)/gtest && \
	tar xf $(BR2_DL_DIR)/gtest-1.5.0.tar.gz -C $(@D)/gtest --strip-components=1
endef

define PROTOBUF_AUTOGEN
	cd $(@D) && \
	$(TARGET_MAKE_ENV) ./autogen.sh
endef

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
