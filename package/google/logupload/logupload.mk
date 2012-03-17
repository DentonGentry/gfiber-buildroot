GOOGLE_LOGUPLOAD_SITE=repo://vendor/google/platform
GOOGLE_LOGUPLOAD_DEPENDENCIES=python iproute2 google_hnvram
GOOGLE_LOGUPLOAD_INSTALL_TARGET=YES

define GOOGLE_LOGUPLOAD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bruno/logupload/upload-logs $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/bruno/logupload/upload-crash-log $(TARGET_DIR)/usr/bin/

	#TODO(apenwarr): This probably belongs in /usr/lib somewhere,
	# especially since we now have so many tools using it.  But if we
	# put it in /usr/lib/python2.7 something in the build scripts deletes it,
	# so let's just put it in /usr/bin for now.
	$(INSTALL) -D -m 0755 $(@D)/bruno/logupload/options.py $(TARGET_DIR)/usr/bin/
endef

$(eval $(call GENTARGETS,package/google,google_logupload))
