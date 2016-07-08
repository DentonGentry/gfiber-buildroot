############################################################
#
# Tremor (Integer decoder for Vorbis)
#
############################################################

TREMOR_SITE = http://svn.xiph.org/trunk/Tremor/
TREMOR_SITE_METHOD = svn
TREMOR_VERSION = 18906

TREMOR_AUTORECONF = YES
TREMOR_INSTALL_STAGING = YES
TREMOR_DEPENDENCIES = libogg

$(eval $(call AUTOTARGETS))
