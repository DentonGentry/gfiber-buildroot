################################################################################
#
# libnetfilter-conntrack
#
################################################################################

# Mindspeed's SDK 2.8.5 uses version 0.9.1 of libnetfilter-conntrack. Let's use
# the same.  That maps to conntrack-tool-1.0.0
CONNTRACK_TOOLS_VERSION = 1.0.0
CONNTRACK_TOOLS_SOURCE = conntrack-tools-$(CONNTRACK_TOOLS_VERSION).tar.bz2
CONNTRACK_TOOLS_SITE = http://www.netfilter.org/projects/conntrack-tools/files
CONNTRACK_TOOLS_INSTALL_STAGING = YES
CONNTRACK_TOOLS_DEPENDENCIES = host-pkg-config libnfnetlink netfilter-conntrack
CONNTRACK_TOOLS_AUTORECONF = YES
CONNTRACK_TOOLS_LICENSE = GPLv2+
CONNTRACK_TOOLS_LICENSE_FILES = COPYING

$(eval $(call AUTOTARGETS))
