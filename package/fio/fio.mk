#############################################################
#
# fio library
#
#############################################################

FIO_VERSION = fio-2.0.1
FIO_SITE = git://git.kernel.dk/fio.git

FIO_DEPENDENCIES = linux libaio

define FIO_BUILD_CMDS
  $(MAKE) CC="$(TARGET_CC)" -C $(@D) DESTDIR="$(TARGET_DIR)" all
endef

define FIO_INSTALL_TARGET_CMDS
  $(MAKE) CC="$(TARGET_CC)" -C $(@D) DESTDIR="$(TARGET_DIR)" install
endef

$(eval $(call GENTARGETS))
