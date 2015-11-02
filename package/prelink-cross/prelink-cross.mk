# prelink-cross
#
# A prelinker which can run on the host and emulate ld.so of
# the target, to support prelinking of cross-compiled binaries.
#
# https://www.yoctoproject.org/tools-resources/projects/cross-prelink

PRELINK_CROSS_VERSION=20151030_cross
PRELINK_CROSS_SITE=http://git.yoctoproject.org/cgit/cgit.cgi/prelink-cross/snapshot/
PRELINK_CROSS_SOURCE=prelink-cross-${PRELINK_CROSS_VERSION}.tar.bz2

HOST_PRELINK_CROSS_AUTORECONF = YES
HOST_PRELINK_CROSS_DEPENDENCIES = host-libelf host-binutils
PRELINK_CROSS_INSTALL_HOST=YES

define PRELINK_CROSS_INSTALL_CONF
	$(INSTALL) -m 0755 -D package/prelink-cross/prelink.conf ${TARGET_DIR}/etc/prelink.conf
endef

ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
PRELINK_CMD="${HOST_DIR}/usr/sbin/prelink --verbose --config-file /etc/prelink.conf --cache-file /etc/prelink.cache --root=${TARGET_DIR} --ld-library-path=/lib:/usr/lib:/usr/local/lib:/chrome/lib:/chrome:/usr/local/lib/webkitGl3:/app/client --dynamic-linker=/lib/ld-uClibc.so.0 --all"
else
PRELINK_CMD="${HOST_DIR}/usr/sbin/prelink --verbose --config-file /etc/prelink.conf --cache-file /etc/prelink.cache --root=${TARGET_DIR} --ld-library-path=/lib:/usr/lib:/usr/local/lib:/chrome/lib:/chrome:/usr/local/lib/webkitGl3:/app/client --all"
endif

HOST_PRELINK_CROSS_POST_INSTALL_HOOKS += PRELINK_CROSS_INSTALL_CONF

# The point of prelink-cross is to run it on the host. We deliberately do not
# provide a way to compile it for the target, only the host.
$(eval $(call AUTOTARGETS,host))
