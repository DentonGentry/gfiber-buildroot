#
# MTR, fullscreen ping/traceroute tool
#

MTR_VERSION = 0.82
MTR_SOURCE = mtr-$(MTR_VERSION).tar.gz
MTR_SITE = ftp://ftp.bitwizard.nl/mtr/
MTR_DEPENDS = pkg-config

$(eval $(call AUTOTARGETS))
