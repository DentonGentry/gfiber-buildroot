#############################################################
#
# google_spacecast
#
#############################################################
GOOGLE_SPACECAST_SITE = repo://vendor/google/spacecast
GOOGLE_SPACECAST_DEPENDENCIES = host-golang \
				go_glog \
				go_gonzojive_mdns \
				go_google_api \
				go_miekg_dns \
				go_net \
				go_protobuf

define GOOGLE_SPACECAST_BUILD_CMDS
	export $(GOLANG_ENV) ; \
	export GOPATH=$(@D)/go:$$GOPATH ; \
	cd $(@D) && go build spacecast/appliance
endef

define GOOGLE_SPACECAST_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/appliance \
		$(TARGET_DIR)/app/spacecast/appliance
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/appliance
endef

define GOOGLE_SPACECAST_CLEAN_CMDS
	export $(GOLANG_ENV) ; \
	export GOPATH=$(@D)/golib:$(@D)/go:$$GOPATH ; \
	cd $(@D) && $(HOST_DIR)/usr/bin/go clean spacecast/appliance
endef

$(eval $(call GENTARGETS))
