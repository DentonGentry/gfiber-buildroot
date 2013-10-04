################################################################################
#
# libnetfilter-conntrack
#
################################################################################

# Mindspeed's SDK 2.8.5 uses version 0.9.1 of libnetfilter-conntrack. Let's use
# the same.
LIBNETFILTER_CONNTRACK_VERSION = 0.9.1
LIBNETFILTER_CONNTRACK_SOURCE = libnetfilter_conntrack-$(LIBNETFILTER_CONNTRACK_VERSION).tar.bz2
LIBNETFILTER_CONNTRACK_SITE = http://www.netfilter.org/projects/libnetfilter_conntrack/files
LIBNETFILTER_CONNTRACK_INSTALL_STAGING = YES
LIBNETFILTER_CONNTRACK_DEPENDENCIES = host-pkg-config libnfnetlink
LIBNETFILTER_CONNTRACK_AUTORECONF = YES
LIBNETFILTER_CONNTRACK_LICENSE = GPLv2+
LIBNETFILTER_CONNTRACK_LICENSE_FILES = COPYING

$(eval $(call AUTOTARGETS))
