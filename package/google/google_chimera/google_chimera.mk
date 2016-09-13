#############################################################
#
# google_chimera
#
#############################################################
GOOGLE_CHIMERA_SITE = repo://vendor/google/wipg
GOOGLE_CHIMERA_DEPENDENCIES = host-protobuf \
				host-golang \
				host-go_mock \
				host-go_protobuf \
				host-pkg-config \
				go_fsnotify \
				go_glog \
				go_golua \
				go_grpc \
				go_luar \
				go_net \
				go_protobuf \
				google_wipg \
				lua \
				mv_physdk \
				mv_cpss
HAL:=chimera-hal

define GOOGLE_CHIMERA_GOENV
	export TARGET_CROSS=$(TARGET_CROSS) ; \
	export STAGING_DIR=$(STAGING_DIR) ; \
	export $(GOLANG_ENV) ; \
	export GOPATH=$(@D)/$(HAL)/proto:$(@D)/$(HAL)/go:$(@D)/$(HAL)/gomock:$$GOPATH ; \
	export CGO_ENABLED=1
endef

define GOOGLE_CHIMERA_PROTOS
	$(GOOGLE_CHIMERA_GOENV) ; export PATH=$(TARGET_PATH) ; \
	$(MAKE) -C $(@D)/$(HAL) OUTDIR=$(@D)/$(HAL) -f chimera.mk protos
endef

GOOGLE_CHIMERA_POST_CONFIGURE_HOOKS += GOOGLE_CHIMERA_PROTOS

define GOOGLE_CHIMERA_BUILD_CMDS
	$(GOOGLE_CHIMERA_GOENV) ; $(MAKE) -C $(@D)/$(HAL) OUTDIR=$(@D)/$(HAL) -f chimera.mk all
endef

define GOOGLE_CHIMERA_TEST_CMDS
	export $(HOST_GOLANG_ENV) ; \
	export GOPATH=$(@D)/$(HAL)/proto:$(@D)/$(HAL)/go:$(@D)/$(HAL)/gomock:$$GOPATH ; \
	$(MAKE) -C $(@D)/$(HAL) OUTDIR=$(@D)/$(HAL) -f chimera.mk test
endef

define GOOGLE_CHIMERA_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D)/$(HAL) OUTDIR=$(@D)/$(HAL) -f chimera.mk install_target \
		INSTALL="$(INSTALL)" \
		TARGET_DIR="$(TARGET_DIR)" \
		STRIPCMD="$(STRIPCMD)"
endef

define GOOGLE_CHIMERA_CLEAN_CMDS
	$(MAKE) -C $(@D)/$(HAL) OUTDIR=$(@D)/$(HAL) -f chimera.mk clean \
		TARGET_DIR="$(TARGET_DIR)"
endef

$(eval $(call GENTARGETS))
