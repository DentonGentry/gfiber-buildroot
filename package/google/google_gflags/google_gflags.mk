#############################################################
#
# google_gflags
#
#############################################################

GOOGLE_GFLAGS_VERSION = 2.1.1
GOOGLE_GFLAGS_SOURCE = v$(GOOGLE_GFLAGS_VERSION).tar.gz
GOOGLE_GFLAGS_SITE = https://github.com/schuhschuh/gflags/archive

GOOGLE_GFLAGS_DIR = $(BUILD_DIR)/google_gflags-$(GOOGLE_GFLAGS_VERSION)
GOOGLE_GFLAGS_INSTALL_STAGING = YES
GOOGLE_GFLAGS_CONF_OPT = -DGFLAGS_NAMESPACE=google -DBUILD_SHARED_LIBS=ON

$(eval $(call CMAKETARGETS))
