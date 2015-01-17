#############################################################
#
# google_spacecast
#
#############################################################
GOOGLE_SPACECAST_SITE = repo://vendor/google/spacecast
GOOGLE_SPACECAST_DEPENDENCIES = host-golang

define GOOGLE_SPACECAST_BUILD_CMDS
	export $(GOLANG_ENV) ; \
	export GOPATH=$(@D)/golib:$(@D)/go:$$GOPATH ; \
	go get -u code.google.com/p/go-uuid/uuid ; \
	go get -u code.google.com/p/go.net/{netutil,ipv4,context} ; \
	go get -u code.google.com/p/google-api-go-client/googleapi ; \
	go get -u code.google.com/p/goprotobuf/proto ; \
	go get -u github.com/golang/glog ; \
	go get -u github.com/miekg/dns ; \
	go get -u github.com/gonzojive/mdns ; \
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
