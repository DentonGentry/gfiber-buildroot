#############################################################
#
# iperf3
#
#############################################################
IPERF3_VERSION = 3.1.1
IPERF3_SOURCE = iperf-$(IPERF3_VERSION).tar.gz
IPERF3_SITE = http://downloads.es.net/pub/iperf/

IPERF3_AUTORECONF = YES

IPERF3_INSTALL_STAGING = NO
IPERF3_INSTALL_TARGET = YES

IPERF3_CONF_ENV = \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_type_bool=yes \
	ac_cv_sizeof_bool=1

IPERF3_CONF_OPT = \
	--disable-dependency-tracking

$(eval $(call AUTOTARGETS))
