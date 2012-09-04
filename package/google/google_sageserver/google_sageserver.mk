GOOGLE_SAGESERVER_SITE = repo://vendor/google/sageserver
GOOGLE_SAGESERVER_DEPENDENCIES = google_skelmir
GOOGLE_SAGESERVER_CL=$(subst files/,,$(shell readlink /google/src/head))

define GOOGLE_SAGESERVER_EXTRACT_CMDS
	mkdir -p $(@D)/google3
endef

define GOOGLE_SAGESERVER_CONFIGURE_CMDS
	echo Using P4 CL$(GOOGLE_MOBILE_API_CL)
	rm -f $(@D)/READONLY
	ln -sf /google/src/files/$(GOOGLE_SAGESERVER_CL)/depot $(@D)/READONLY
endef

define GOOGLE_SAGESERVER_BUILD_CMDS
	cd $(@D)/build/bruno/sage && ./buildsage.sh
	cd $(@D)/google3 && \
	blaze --host_jvm_args=-Xmx256m build \
		--noshow_progress \
		--package_path .:../READONLY/google3 \
		--forge -- \
		//java/com/google/fiber/mobile/plugin:gftv_mobile_api_deploy.jar
endef

#TODO(apenwarr): There are probably unnecessary files included here.
#  I just wrote it to duplicate as precisely as possible the set of files
#  that were included in the earlier manually-generated tarball releases of
#  the sageserver.  I have a strong feeling there's extra cruft that
#  accumulated over time.  (For example, the fonts in two different places,
#  and the two files named [Aa]pache.jar, which contain different things
#  and so should have better names.)  I also think we're not supposed
#  to refer to build/hd300 anymore, but some of the files don't exist
#  elsewhere (yet?)
define GOOGLE_SAGESERVER_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/app/sage/STVs \
		 $(TARGET_DIR)/app/sage/images \
		 $(TARGET_DIR)/app/sage/skelmir/Libraries
	cp -af	$(@D)/build/bruno/sage/jars/*.jar \
		$(@D)/build/bruno/sage/Sage.jar \
		$(@D)/build/bruno/sage/webserver/* \
		$(@D)/stvs/fonts \
		$(@D)/build/bruno/sage/Monospaced*.ttf \
		$(TARGET_DIR)/app/sage/
	rm -f	$(TARGET_DIR)/app/sage/Apache.jar \
		$(TARGET_DIR)/app/sage/Standard.jar
	cp -af	$(@D)/stvs/FiberTV \
		$(TARGET_DIR)/app/sage/STVs/
	rm -f	$(TARGET_DIR)/app/sage/STVs/FiberTV/FiberTV7.xml
	cp -f	$(@D)/images/SageTV/images/tvicon* \
		$(TARGET_DIR)/app/sage/images/
	cp -af	package/google/google_sageserver/Sage.properties.defaults.* \
		package/google/google_sageserver/runsage \
		package/google/google_sageserver/runsageclient \
		$(TARGET_DIR)/app/sage/
	ln -sf	/tmp/Sage.properties.defaults \
		$(TARGET_DIR)/app/sage/Sage.properties.defaults
	$(INSTALL) -m 0755 -D package/google/google_sageserver/S95sageserver \
		$(TARGET_DIR)/etc/init.d/S95sageserver
	cp -af $(@D)/READONLY/google3/java/com/google/fiber/mobile/plugin/plugin.properties \
		$(TARGET_DIR)/app/sage/Sage.properties.defaults.mobileapi
        cp -af $(@D)/google3/blaze-bin/java/com/google/fiber/mobile/plugin/gftv_mobile_api_deploy.jar \
		$(TARGET_DIR)/app/sage/
endef

$(eval $(call GENTARGETS))
