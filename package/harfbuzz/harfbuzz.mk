#############################################################
#
# harfbuzz
#
#############################################################
HARFBUZZ_VERSION = 1.0.1
HARFBUZZ_SITE = http://www.freedesktop.org/software/harfbuzz/release
HARFBUZZ_SOURCE = harfbuzz-$(HARFBUZZ_VERSION).tar.bz2
HARFBUZZ_INSTALL_STAGING = YES
HARFBUZZ_CONF_OPT = --with-coretext=no --with-uniscribe=no --with-cairo=no

HOST_HARFBUZZ_DEPENDENCIES = \
	host-freetype \
	host-libglib2

HOST_HARFBUZZ_CONF_OPT = \
	--with-coretext=no \
	--with-uniscribe=no \
	--with-graphite2=no \
	--with-cairo=no \
	--with-icu=no \
	--with-freetype=yes \
	--with-glib=yes

ifeq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
# forgets to link test programs with -pthread breaking static link
HARFBUZZ_CONF_ENV = LDFLAGS="$(TARGET_LDFLAGS) -pthread"
endif

ifeq ($(BR2_PACKAGE_FREETYPE),y)
HARFBUZZ_DEPENDENCIES += freetype
HARFBUZZ_CONF_OPT += --with-freetype=yes
else
HARFBUZZ_CONF_OPT += --with-freetype=no
endif

ifeq ($(BR2_PACKAGE_GRAPHITE2),y)
HARFBUZZ_DEPENDENCIES += graphite2
HARFBUZZ_CONF_OPT += --with-graphite2=yes
else
HARFBUZZ_CONF_OPT += --with-graphite2=no
endif

ifeq ($(BR2_PACKAGE_LIBGLIB2),y)
HARFBUZZ_DEPENDENCIES += libglib2
HARFBUZZ_CONF_OPT += --with-glib=yes
else
HARFBUZZ_CONF_OPT += --with-glib=no
endif

ifeq ($(BR2_PACKAGE_ICU),y)
HARFBUZZ_DEPENDENCIES += icu
HARFBUZZ_CONF_OPT += --with-icu=yes
else
HARFBUZZ_CONF_OPT += --with-icu=no
endif

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))
