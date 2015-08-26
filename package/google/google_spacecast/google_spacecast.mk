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
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S80statemanager \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S82scdaemon \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S84configmanager \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S88updateengine \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S90spacecast \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S92monlogpusher\
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S95adb\
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S99androidserver\
		$(TARGET_DIR)/etc/init.d/
	if [ "$(BR2_PACKAGE_GOOGLE_PROD)" = "y" ]; then \
		$(INSTALL) -D -m 0755 package/google/google_spacecast/prodsysinfo \
			$(TARGET_DIR)/sbin; \
	fi
endef

define GOOGLE_SPACECAST_CLEAN_CMDS
	$(MAKE) -C $(@D) OUTDIR=$(@D) -f spacecast.mk clean \
		TARGET_DIR="$(TARGET_DIR)"

	rm -f $(TARGET_DIR)/etc/init.d/S80statemanager
	rm -f $(TARGET_DIR)/etc/init.d/S82scdaemon
	rm -f $(TARGET_DIR)/etc/init.d/S84configmanager
	rm -f $(TARGET_DIR)/etc/init.d/S88updateengine
	rm -f $(TARGET_DIR)/etc/init.d/S90spacecast
	rm -f $(TARGET_DIR)/etc/init.d/S92monlogpusher
	rm -f $(TARGET_DIR)/etc/init.d/S95adb
	rm -f $(TARGET_DIR)/etc/init.d/S99androidserver
endef

$(eval $(call GENTARGETS))
