#############################################################
#
# google_spacecast
#
#############################################################
GOOGLE_SPACECAST_SITE = repo://vendor/google/spacecast
GOOGLE_SPACECAST_DEPENDENCIES = host-golang \
				host-go_protobuf \
				go_fsnotify \
				go_glog \
				go_gonzojive_mdns \
				go_google_api \
				go_guelfey_go_dbus \
				go_miekg_dns \
				go_net \
				go_protobuf \
				google_widevine_cenc

GOOGLE_SPACECAST_GEN_PROTO = \
	cd $(@D); \
        mkdir -p $(@D)/proto/src/spacecast/proto/$(1)_proto ; \
	export PATH=$(TARGET_PATH) ; \
        protoc --go_out=$(@D)/proto/src/spacecast/proto/$(1)_proto \
		$(@D)/go/src/spacecast/proto/$(1).proto \
		-I$(@D)/go/src/spacecast/proto \
		-I$(@D)/go/src

define GOOGLE_SPACECAST_BUILD_CMDS
	$(call GOOGLE_SPACECAST_GEN_PROTO,auth)
	$(call GOOGLE_SPACECAST_GEN_PROTO,device)
	$(call GOOGLE_SPACECAST_GEN_PROTO,feeds)
	$(call GOOGLE_SPACECAST_GEN_PROTO,file_encrypt)
	$(call GOOGLE_SPACECAST_GEN_PROTO,spacecast_api)
	$(call GOOGLE_SPACECAST_GEN_PROTO,video_corpus)

        sed -i s/\.pb/_proto/ $(@D)/proto/src/spacecast/proto/spacecast_api_proto/spacecast_api.pb.go

	export $(GOLANG_ENV) ; \
	export GOPATH=$(@D)/go:$(@D)/proto:$$GOPATH ; \
	export CGO_ENABLED=1 ; \
	cd $(@D) && go build spacecast/appliance; \
	cd $(@D) && go build spacecast/appliance/statemanager
endef

define GOOGLE_SPACECAST_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/appliance \
		$(TARGET_DIR)/app/spacecast/appliance
	$(INSTALL) -D -m 0755 $(@D)/statemanager \
		$(TARGET_DIR)/app/spacecast/statemanager
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/appliance
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/statemanager
	$(INSTALL) -D -m 0755 package/google/google_spacecast/S90spacecast \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/S85statemanager \
		$(TARGET_DIR)/etc/init.d/
	mkdir -p $(TARGET_DIR)/etc/dbus-1/system.d
	$(INSTALL) -D -m 0644 package/google/google_spacecast/com.google.spacecast.StateManager.conf \
		$(TARGET_DIR)/etc/dbus-1/system.d/
endef

define GOOGLE_SPACECAST_CLEAN_CMDS
	export $(GOLANG_ENV) ; \
	export GOPATH=$(@D)/golib:$(@D)/go:$$GOPATH ; \
	export CGO_ENABLED=1 ; \
	cd $(@D) && $(HOST_DIR)/usr/bin/go clean spacecast/appliance spacecast/appliance/statemanager; \
	rm -f $(TARGET_DIR)/etc/init.d/S90spacecast
	rm -f $(TARGET_DIR)/etc/init.d/S85statemanager
	rm -f $(TARGET_DIR)/etc/dbus-1/system.d/com.google.spacecast.StateManager.conf
endef

$(eval $(call GENTARGETS))
