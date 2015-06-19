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
	$(INSTALL) -D -m 0755 $(@D)/appliance \
		$(TARGET_DIR)/app/spacecast/appliance
	$(INSTALL) -D -m 0755 $(@D)/daemon \
		$(TARGET_DIR)/app/spacecast/daemon
	$(INSTALL) -D -m 0755 $(@D)/configmanager \
		$(TARGET_DIR)/app/spacecast/configmanager
	$(INSTALL) -D -m 0755 $(@D)/statemanager \
		$(TARGET_DIR)/app/spacecast/statemanager
	$(INSTALL) -D -m 0755 $(@D)/tunermanager \
		$(TARGET_DIR)/app/spacecast/tunermanager
	$(INSTALL) -D -m 0755 $(@D)/updatebroker \
		$(TARGET_DIR)/app/spacecast/updatebroker
	$(INSTALL) -D -m 0755 $(@D)/updateengine \
		$(TARGET_DIR)/app/spacecast/updateengine
	$(INSTALL) -D -m 0755 $(@D)/monlog_token_refresher \
		$(TARGET_DIR)/app/spacecast/monlog_token_refresher
	$(INSTALL) -D -m 0755 $(@D)/tpmverify \
		$(TARGET_DIR)/app/spacecast/tpmverify
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/appliance
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/daemon
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/configmanager
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/statemanager
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/tunermanager
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/monlog_token_refresher
	$(STRIPCMD) $(TARGET_DIR)/app/spacecast/tpmverify
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S90spacecast \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S88scdaemon \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S92configmanager \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S85statemanager \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S91tunermanager \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S87updatebroker \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S89updateengine \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 package/google/google_spacecast/etc/init.d/S80monlog_token_refresher \
		$(TARGET_DIR)/etc/init.d/
	mkdir -p $(TARGET_DIR)/etc/dbus-1/system.d
	$(INSTALL) -D -m 0644 package/google/google_spacecast/etc/dbus-1/system.d/com.google.spacecast.ConfigManager.conf \
		$(TARGET_DIR)/etc/dbus-1/system.d/
	$(INSTALL) -D -m 0644 package/google/google_spacecast/etc/dbus-1/system.d/com.google.spacecast.StateManager.conf \
		$(TARGET_DIR)/etc/dbus-1/system.d/
	$(INSTALL) -D -m 0644 package/google/google_spacecast/etc/dbus-1/system.d/com.google.spacecast.UpdateBroker.conf \
		$(TARGET_DIR)/etc/dbus-1/system.d/
	$(INSTALL) -D -m 0644 package/google/google_spacecast/etc/dbus-1/system.d/com.google.spacecast.UpdateEngine.conf \
	$(INSTALL) -D -m 0644 package/google/google_spacecast/etc/dbus-1/system.d/com.google.spacecast.Authorizer.conf \
		$(TARGET_DIR)/etc/dbus-1/system.d/

	# Buffet command and state definitions
	# FIXME TODO(efirst): Modify buffet.conf to use prod GCD instead of staging and prod credentials before release.
	mkdir -p $(TARGET_DIR)/etc/buffet && \
	$(INSTALL) -m 0755 -D package/google/google_spacecast/etc/buffet/buffet.conf $(TARGET_DIR)/etc/buffet
	# FIXME TODO(efirst): Replace JSON files with array versions once supported by Buffet (https://code.google.com/p/brillo/issues/detail?id=107).
	mkdir -p $(TARGET_DIR)/etc/buffet/commands && \
	$(INSTALL) -m 0755 -D package/google/google_spacecast/etc/buffet/commands/sc-configuration.json $(TARGET_DIR)/etc/buffet/commands
	mkdir -p $(TARGET_DIR)/etc/buffet/states && \
	$(INSTALL) -m 0755 -D package/google/google_spacecast/etc/buffet/states/sc-configuration.schema.json $(TARGET_DIR)/etc/buffet/states

	# Monlog oauth credentials
	# FIXME TODO(zchen): Modify oauth2_credentials.json to use Spacecast prod credentials
	# instead of staging before release
	mkdir -p $(TARGET_DIR)/etc/monlog && \
	$(INSTALL) -m 0755 -D package/google/google_spacecast/etc/monlog/oauth2_credentials.json $(TARGET_DIR)/etc/monlog
	# FIXME TODO(zchen): monlog_token_file.json should be initialized via the registration process.
	$(INSTALL) -m 0755 -D package/google/google_spacecast/etc/monlog/monlog_token_file.json $(TARGET_DIR)/etc/monlog
endef

define GOOGLE_SPACECAST_CLEAN_CMDS
	$(MAKE) -C $(@D) OUTDIR=$(@D) -f spacecast.mk clean
	rm -f $(TARGET_DIR)/etc/init.d/S90spacecast
	rm -f $(TARGET_DIR)/etc/init.d/S88scdaemon
	rm -f $(TARGET_DIR)/etc/init.d/S92configmanager
	rm -f $(TARGET_DIR)/etc/init.d/S85statemanager
	rm -f $(TARGET_DIR)/etc/init.d/S91tunermanager
	rm -f $(TARGET_DIR)/etc/init.d/S80monlog_token_refresher
	rm -f $(TARGET_DIR)/etc/dbus-1/system.d/com.google.spacecast.ConfigManager.conf
	rm -f $(TARGET_DIR)/etc/dbus-1/system.d/com.google.spacecast.StateManager.conf
	rm -f $(TARGET_DIR)/etc/dbus-1/system.d/com.google.spacecast.UpdateBroker.conf
	rm -f $(TARGET_DIR)/etc/dbus-1/system.d/com.google.spacecast.Authorizer.conf
endef

$(eval $(call GENTARGETS))
