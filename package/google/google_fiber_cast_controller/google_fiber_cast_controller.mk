#############################################################
#
# google_fiber_cast_controller
#
#############################################################

GOOGLE_FIBER_CAST_CONTROLLER_SITE = repo://google_cast
GOOGLE_FIBER_CAST_CONTROLLER_DEPENDENCIES=google_dart_vm

define GOOGLE_FIBER_CAST_CONTROLLER_BUILD_CMDS
	TARGET=$(TARGET_CROSS) \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	INCLUDES=-I$(STAGING_DIR)/usr/local \
	$(MAKE) -C $(@D)/fiber/fibercastcontroller
endef

define GOOGLE_FIBER_CAST_CONTROLLER_INSTALL_TARGET_CMDS
	DESTDIR=$(TARGET_DIR) \
	INSTALL=$(INSTALL) \
	$(MAKE) -C $(@D)/fiber/fibercastcontroller install
endef

$(eval $(call GENTARGETS))
