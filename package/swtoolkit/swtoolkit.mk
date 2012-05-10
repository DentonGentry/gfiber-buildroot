SWTOOLKIT_SITE = http://swtoolkit.googlecode.com/svn/trunk/
SWTOOLKIT_SITE_METHOD = svn
SWTOOLKIT_VERSION = r72
SWTOOLKIT_INSTALL_PATH = usr/lib/swtoolkit

define HOST_SWTOOLKIT_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/usr/lib
	ln -sf $(@D) $(HOST_DIR)/$(SWTOOLKIT_INSTALL_PATH)
endef

$(eval $(call GENTARGETS))
