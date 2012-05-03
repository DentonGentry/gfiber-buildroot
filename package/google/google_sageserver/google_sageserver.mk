GOOGLE_SAGESERVER_SITE = repo://vendor/google/sageserver
GOOGLE_SAGESERVER_DEPENDENCIES = google_skelmir

define GOOGLE_SAGESERVER_BUILD_CMDS
	cd $(@D)/build/bruno/sage && ./buildsage.sh
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
		$(@D)/stvs/fonts \
		$(TARGET_DIR)/app/sage/
	rm -f	$(TARGET_DIR)/app/sage/Apache.jar \
		$(TARGET_DIR)/app/sage/Standard.jar
	cp -af	$(@D)/stvs/SageTV7 $(@D)/stvs/FiberTV \
		$(TARGET_DIR)/app/sage/STVs/
	rm -f	$(TARGET_DIR)/app/sage/STVs/FiberTV/FiberTV7.xml \
		$(TARGET_DIR)/app/sage/STVs/SageTV7/SageTV7.xml
	cp -f	$(@D)/images/SageTV/images/tvicon* \
		$(TARGET_DIR)/app/sage/images/
	cp -af	package/google/google_sageserver/Sage.properties.defaults \
		package/google/google_sageserver/runsage \
		package/google/google_sageserver/runsageclient \
		package/google/google_sageserver/sagesrv.sh \
		$(TARGET_DIR)/app/sage/
	$(INSTALL) -m 0755 -D package/google/google_sageserver/S95sageserver \
		$(TARGET_DIR)/etc/init.d/S95sageserver
endef

$(eval $(call GENTARGETS_NEW))
