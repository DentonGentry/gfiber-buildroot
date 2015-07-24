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
				go_godbus_dbus \
				go_gonzojive_mdns \
				go_google_api \
				go_grpc \
				go_miekg_dns \
				go_net \
				go_oauth2 \
				go_protobuf \
				go_shanemhansen_gossl \
				go_tpm \
				google_widevine_cenc

define GOOGLE_SPACECAST_GOENV
	export $(GOLANG_ENV) ; \
	export GOPATH=$(@D)/go:$(@D)/gomock:$(@D)/proto:$$GOPATH ; \
	export CGO_ENABLED=1
endef

define GOOGLE_SPACECAST_PROTOS
	$(GOOGLE_SPACECAST_GOENV) ; export PATH=$(TARGET_PATH) ; \
	$(MAKE) -C $(@D) OUTDIR=$(@D) -f spacecast.mk protos
endef

GOOGLE_SPACECAST_POST_CONFIGURE_HOOKS += GOOGLE_SPACECAST_PROTOS

define GOOGLE_SPACECAST_BUILD_CMDS
	$(GOOGLE_SPACECAST_GOENV) ; $(MAKE) -C $(@D) OUTDIR=$(@D) -f spacecast.mk all
endef

define GOOGLE_SPACECAST_TEST_CMDS
	export $(HOST_GOLANG_ENV) ; \
	export GOPATH=$(@D)/go:$(@D)/gomock:$(@D)/proto:$$GOPATH ; \
	$(MAKE) -C $(@D) OUTDIR=$(@D) -f spacecast.mk test
endef

define GOOGLE_SPACECAST_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D) OUTDIR=$(@D) -f spacecast.mk install_target \
		INSTALL="$(INSTALL)" \
		TARGET_DIR="$(TARGET_DIR)" \
		STRIPCMD="$(STRIPCMD)"
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S90spacecast \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S88scdaemon \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S92configmanager \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S85statemanager \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S89updateengine \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S80monlog_pusher\
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S99androidserver\
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S95adb\
		$(TARGET_DIR)/etc/init.d/
endef

define GOOGLE_SPACECAST_CLEAN_CMDS
	$(MAKE) -C $(@D) OUTDIR=$(@D) -f spacecast.mk clean \
		TARGET_DIR="$(TARGET_DIR)"

	rm -f $(TARGET_DIR)/etc/init.d/S90spacecast
	rm -f $(TARGET_DIR)/etc/init.d/S88scdaemon
	rm -f $(TARGET_DIR)/etc/init.d/S92configmanager
	rm -f $(TARGET_DIR)/etc/init.d/S85statemanager
	rm -f $(TARGET_DIR)/etc/init.d/S89updateengine
	rm -f $(TARGET_DIR)/etc/init.d/S80monlog_pusher
	rm -f $(TARGET_DIR)/etc/init.d/S99androidserver
	rm -f $(TARGET_DIR)/etc/init.d/S95adb
endef

$(eval $(call GENTARGETS))
