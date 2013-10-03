################################################################################
#
# libnfnetlink
#
################################################################################

# Mindspeed's SDK 2.8.5 uses version 1.0.0 of libnfnetlink. Let's use the same.
LIBNFNETLINK_VERSION = 1.0.0
LIBNFNETLINK_SOURCE = libnfnetlink-$(LIBNFNETLINK_VERSION).tar.bz2
LIBNFNETLINK_SITE = http://www.netfilter.org/projects/libnfnetlink/files
LIBNFNETLINK_AUTORECONF = YES
LIBNFNETLINK_INSTALL_STAGING = YES

$(eval $(call AUTOTARGETS))
