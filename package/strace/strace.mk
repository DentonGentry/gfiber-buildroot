#############################################################
#
# strace
#
#############################################################

STRACE_VERSION = 4.14
STRACE_SOURCE = strace-$(STRACE_VERSION).tar.xz
STRACE_SITE = http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/strace

ifneq ($(BR2_PACKAGE_LIBAIO),)
STRACE_DEPENDENCIES += libaio
endif

STRACE_CONF_ENV = ac_cv_header_linux_if_packet_h=yes \
		  ac_cv_header_linux_netlink_h=yes \
	          $(if $(BR2_LARGEFILE),ac_cv_type_stat64=yes,ac_cv_type_stat64=no)

define STRACE_REMOVE_STRACE_GRAPH
	rm -f $(TARGET_DIR)/usr/bin/strace-graph
endef

STRACE_POST_INSTALL_TARGET_HOOKS += STRACE_REMOVE_STRACE_GRAPH

$(eval $(call AUTOTARGETS))
