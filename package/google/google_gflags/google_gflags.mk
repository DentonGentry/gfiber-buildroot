#############################################################
#
# google_gflags
#
#############################################################

GOOGLE_GFLAGS_VERSION = v2.1.2
GOOGLE_GFLAGS_SITE = git://github.com/gflags/gflags.git

GOOGLE_GFLAGS_DIR = $(BUILD_DIR)/google_gflags-$(GOOGLE_GFLAGS_VERSION)
GOOGLE_GFLAGS_INSTALL_STAGING = YES
GOOGLE_GFLAGS_INSTALL_TARGET = YES
GOOGLE_GFLAGS_CONF_OPT = -DGFLAGS_NAMESPACE=google -DBUILD_SHARED_LIBS=ON

$(eval $(call CMAKETARGETS))
$(eval $(call CMAKETARGETS,host))
