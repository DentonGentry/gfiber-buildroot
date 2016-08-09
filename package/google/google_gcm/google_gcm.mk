#############################################################
#
# google_gcm
#
#############################################################
GOOGLE_GCM_SITE = repo://vendor/google/gcm
GOOGLE_GCM_DEPENDENCIES = 	host-protobuf \
				host-golang \
				host-go_protobuf \
				host-go_mock \
				go_glog \
				go_protobuf \

define GOOGLE_GCM_GOENV
	export GOPATH=$(@D)/proto:$(@D)/go:$(@D)/gomock:$$GOPATH ; \
	export CGO_ENABLED=1
endef

define GOOGLE_GCM_BUILD_CMDS
	export $(GOLANG_ENV) ; \
	$(GOOGLE_GCM_GOENV); \
	$(MAKE) -C $(@D) OUTDIR=$(@D) -f gcm.mk all
endef

define GOOGLE_GCM_TEST_CMDS
	export $(HOST_GOLANG_ENV) ; \
	$(GOOGLE_GCM_GOENV); \
	export CGO_CXXFLAGS="$(HOST_CXXFLAGS)" ; \
	export CGO_LDFLAGS="$(HOST_LDFLAGS)" ; \
	$(MAKE) -C $(@D) OUTDIR=$(@D) -f gcm.mk test
endef

define GOOGLE_GCM_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D) OUTDIR=$(@D) -f gcm.mk install_target \
		INSTALL="$(INSTALL)" \
		TARGET_DIR="$(TARGET_DIR)" \
		STRIPCMD="$(STRIPCMD)"
	mkdir -p $(TARGET_DIR)/rw/gfcm/
	$(INSTALL) -m 0755 -D package/google/google_gcm/S94gfcm \
		$(TARGET_DIR)/etc/init.d/S94gfcm
endef

define GOOGLE_GCM_CLEAN_CMDS
	$(MAKE) -C $(@D) OUTDIR=$(@D) -f gcm.mk clean \
		TARGET_DIR="$(TARGET_DIR)"
endef

$(eval $(call GENTARGETS))
