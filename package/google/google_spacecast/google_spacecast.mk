#############################################################
#
# google_spacecast
#
#############################################################
GOOGLE_SPACECAST_SITE = repo://vendor/google/spacecast
GOOGLE_SPACECAST_DEPENDENCIES = host-protobuf \
				host-golang \
				host-go_protobuf \
				host-go_mock \
				go_fsnotify \
				go_glog \
				go_gonzojive_mdns \
				go_google_api \
				go_guelfey_go_dbus \
				go_miekg_dns \
				go_net \
				go_oauth2 \
				go_protobuf \
				google_widevine_cenc

define GOOGLE_SPACECAST_GOENV
	export $(GOLANG_ENV) ; \
	export GOPATH=$(@D)/go:$(@D)/gomock:$(@D)/proto:$$GOPATH ; \
	export CGO_ENABLED=1
endef

define GOOGLE_SPACECAST_GEN_PROTO
	mkdir -p $(@D)/proto/src/spacecast/proto/$(1)_proto
	export PATH=$(TARGET_PATH) ; \
	protoc --go_out=$(@D)/proto/src/spacecast/proto/$(1)_proto \
		$(@D)/go/src/spacecast/proto/$(1).proto \
		-I$(@D)/go/src/spacecast/proto \
		-I$(@D)/go/src
endef

define GOOGLE_SPACECAST_GEN_MOCK
	mkdir -p $(@D)/gomock/src/$(dir $(1))/mock_$(notdir $(1))
	$(GOOGLE_SPACECAST_GOENV) ; \
	export PATH=$(TARGET_PATH) ; \
	GOARCH= mockgen $(1) $(2) > $(@D)/gomock/src/$(dir $(1))/mock_$(notdir $(1))/$(2).go
endef

define GOOGLE_SPACECAST_PROTOS
	$(call GOOGLE_SPACECAST_GEN_PROTO,auth)
	$(call GOOGLE_SPACECAST_GEN_PROTO,device)
	$(call GOOGLE_SPACECAST_GEN_PROTO,crypto)
	$(call GOOGLE_SPACECAST_GEN_PROTO,feeds)
	$(call GOOGLE_SPACECAST_GEN_PROTO,spacecast_api)
	$(call GOOGLE_SPACECAST_GEN_PROTO,storage)

	find $(@D)/proto/src/spacecast/proto -name "*.pb.go" | xargs sed -i s/\.pb/_proto/
endef

GOOGLE_SPACECAST_POST_CONFIGURE_HOOKS += GOOGLE_SPACECAST_PROTOS

define GOOGLE_SPACECAST_MOCKS
	$(call GOOGLE_SPACECAST_GEN_MOCK,spacecast/appliance/adaptor,Cache)
	$(call GOOGLE_SPACECAST_GEN_MOCK,spacecast/appliance/buffet,CommandProxy)
	$(call GOOGLE_SPACECAST_GEN_MOCK,spacecast/appliance/dbus,DBusConn)
	$(call GOOGLE_SPACECAST_GEN_MOCK,spacecast/appliance/dbus,DBusObject)
	$(call GOOGLE_SPACECAST_GEN_MOCK,spacecast/appliance/fsnotify,FsnotifyWatcher)
	$(call GOOGLE_SPACECAST_GEN_MOCK,spacecast/appliance/signature_validator/signature,Validator)
	$(call GOOGLE_SPACECAST_GEN_MOCK,spacecast/common/api/client,Service)
	$(call GOOGLE_SPACECAST_GEN_MOCK,spacecast/common/flute,Decoder)
	$(call GOOGLE_SPACECAST_GEN_MOCK,spacecast/common/storage/cache,Manager)
endef

GOOGLE_SPACECAST_POST_CONFIGURE_HOOKS += GOOGLE_SPACECAST_MOCKS

define GOOGLE_SPACECAST_BUILD_CMDS
	$(GOOGLE_SPACECAST_GOENV) ; \
	cd $(@D) && go build -tags widevine spacecast/appliance; \
	cd $(@D) && go build spacecast/appliance/statemanager;  \
	cd $(@D) && go build spacecast/appliance/monlog_token_refresher
endef

define GOOGLE_SPACECAST_TEST_CMDS
	export $(HOST_GOLANG_ENV) ; \
	export GOPATH=$(@D)/go:$(@D)/gomock:$(@D)/proto:$$GOPATH ; \
	go test spacecast/...
endef

define GOOGLE_SPACECAST_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/appliance \
		$(TARGET_DIR)/app/spacecast/appliance
	$(INSTALL) -D -m 0755 $(@D)/statemanager \
		$(TARGET_DIR)/app/spacecast/statemanager
	$(INSTALL) -D -m 0755 $(@D)/monlog_token_refresher \
		$(TARGET_DIR)/app/spacecast/monlog_token_refresher
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/appliance
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/statemanager
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/monlog_token_refresher
	$(INSTALL) -D -m 0755 package/google/google_spacecast/S90spacecast \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/S85statemanager \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/S80monlog_token_refresher \
		$(TARGET_DIR)/etc/init.d/
	mkdir -p $(TARGET_DIR)/etc/dbus-1/system.d
	$(INSTALL) -D -m 0644 package/google/google_spacecast/com.google.spacecast.StateManager.conf \
		$(TARGET_DIR)/etc/dbus-1/system.d/

	# Buffet command and state definitions
	# FIXME TODO(efirst): Modify buffet.conf to use prod GCD instead of staging and prod credentials before release.
	mkdir -p $(TARGET_DIR)/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_spacecast/buffet.conf $(TARGET_DIR)/etc/buffet
	# FIXME TODO(efirst): Replace JSON files with array versions once supported by Buffet (https://code.google.com/p/brillo/issues/detail?id=107).
	mkdir -p $(TARGET_DIR)/etc/buffet/commands && \
	$(INSTALL) -m 0755 -D package/google/google_spacecast/sc-configuration.json $(TARGET_DIR)/etc/buffet/commands
	mkdir -p $(TARGET_DIR)/etc/buffet/states && \
	$(INSTALL) -m 0755 -D package/google/google_spacecast/sc-configuration.schema.json $(TARGET_DIR)/etc/buffet/states

	# Monlog oauth credentials
	# FIXME TODO(zchen): Modify oauth2_credentials.json to use Spacecast prod credentials
	# instead of staging before release
	mkdir -p $(TARGET_DIR)/etc/monlog && \
	$(INSTALL) -m 0755 -D package/google/google_spacecast/oauth2_credentials.json $(TARGET_DIR)/etc/monlog
	# FIXME TODO(zchen): monlog_token_file.json should be initialized via the registration process.
	$(INSTALL) -m 0755 -D package/google/google_spacecast/monlog_token_file.json $(TARGET_DIR)/etc/monlog
endef

define GOOGLE_SPACECAST_CLEAN_CMDS
	rm -f $(TARGET_DIR)/etc/init.d/S90spacecast
	rm -f $(TARGET_DIR)/etc/init.d/S85statemanager
	rm -f $(TARGET_DIR)/etc/init.d/S80monlog_token_refresher
	rm -f $(TARGET_DIR)/etc/dbus-1/system.d/com.google.spacecast.StateManager.conf
endef

$(eval $(call GENTARGETS))
