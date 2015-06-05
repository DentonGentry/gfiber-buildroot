###############################################################################
#
# trace-cmd
#
###############################################################################

TRACE_CMD_VERSION = 2.5.3
TRACE_CMD_SOURCE = trace-cmd-v$(TRACE_CMD_VERSION).tar.gz
TRACE_CMD_SITE = https://kernel.googlesource.com/pub/scm/linux/kernel/git/rostedt/trace-cmd.git/+archive
TRACE_CMD_LICENSE = GPLv2+
TRACE_CMD_LICENSE_FILES = COPYING

# manually extract this tarball, since it lacks the expected enclosing directory.
define TRACE_CMD_EXTRACT_CMDS
	$(TAR) $(TAR_OPTIONS) $(DL_DIR)/$(TRACE_CMD_SOURCE) $(TAR_STRIP_COMPONENTS)=0 -C $(TRACE_CMD_DIR)
endef

define TRACE_CMD_BUILD_CMDS
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D) NO_PYTHON=1 all_cmd
endef

define TRACE_CMD_INSTALL_TARGET_CMDS
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D) NO_PYTHON=1 DESTDIR="$(TARGET_DIR)" install
endef

$(eval $(call GENTARGETS))
