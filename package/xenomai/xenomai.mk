#############################################################
# Xenomai
# URL  : http://xenomai.org
# NOTE : Real-Time Framework for Linux
#
#############################################################

XENOMAI_VERSION = $(call qstrip,$(BR2_PACKAGE_XENOMAI_VERSION))
ifeq ($(XENOMAI_VERSION),)
XENOMAI_VERSION = 2.5.6
endif

XENOMAI_SITE = http://download.gna.org/xenomai/stable/
XENOMAI_SOURCE = xenomai-$(XENOMAI_VERSION).tar.bz2

XENOMAI_INSTALL_STAGING = YES

ifeq ($(BR2_arm),y)
XENOMAI_CPU_TYPE = $(call qstrip,$(BR2_PACKAGE_XENOMAI_CPU_TYPE))
# Set "generic" if not defined
ifeq ($(XENOMAI_CPU_TYPE),)
XENOMAI_CPU_TYPE = generic
endif
XENOMAI_CONF_OPT += --enable-arm-mach=$(XENOMAI_CPU_TYPE)
endif #BR2_arm

ifeq ($(BR2_PACKAGE_XENOMAI_SMP),y)
XENOMAI_CONF_OPT += --enable-smp
endif

# The configure step needs to be overloaded, because Xenomai doesn't
# support --prefix=/usr and the autotargets infrastructure enforces
# this.
define XENOMAI_CONFIGURE_CMDS
	(cd $(@D); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		CCFLAGS_FOR_BUILD="$(HOST_CFLAGS)" \
		./configure \
		$(XENOMAI_CONF_OPT) \
		--host=$(GNU_TARGET_NAME) \
	)
endef

ifeq ($(BR2_HAVE_DOCUMENTATION),)
define XENOMAI_REMOVE_DOCUMENTATION
	rm -rf $(TARGET_DIR)/usr/xenomai/share/doc
	rm -rf $(TARGET_DIR)/usr/xenomai/share/man
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_REMOVE_DOCUMENTATION
endif

ifeq ($(BR2_HAVE_DEVFILES),)
define XENOMAI_REMOVE_DEVFILES
	rm -rf $(TARGET_DIR)/usr/xenomai/include
	for i in xeno-config xeno-info wrap-link.sh ; do \
		rm -f $(TARGET_DIR)/usr/xenomai/bin/$$i ; \
	done
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_REMOVE_DEVFILES
endif

ifeq ($(BR2_PACKAGE_XENOMAI_TESTSUITE),)
define XENOMAI_REMOVE_TESTSUITE
	rm -rf $(TARGET_DIR)/usr/xenomai/share/xenomai/testsuite/
	rmdir --ignore-fail-on-non-empty $(TARGET_DIR)/usr/xenomai/share/xenomai/
	rmdir --ignore-fail-on-non-empty $(TARGET_DIR)/usr/xenomai/share/
	for i in klatency rtdm xeno xeno-load check-vdso \
		irqloop cond-torture-posix switchtest arith \
		sigtest clocktest cyclictest latency wakeup-time \
		xeno-test cond-torture-native mutex-torture-posix \
		mutex-torture-native ; do \
		rm -f $(TARGET_DIR)/usr/xenomai/bin/$$i ; \
	done
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_REMOVE_TESTSUITE
endif

define XENOMAI_ADD_LD_SO_CONF
	# Add /usr/xenomai/lib in the library search path
	grep -q "^/usr/xenomai/lib" $(TARGET_DIR)/etc/ld.so.conf || \
		echo "/usr/xenomai/lib" >> $(TARGET_DIR)/etc/ld.so.conf
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_ADD_LD_SO_CONF

# If you use static /dev creation don't forget to update your
#  device_table_dev.txt
ifeq ($(BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_UDEV),y)
XENOMAI_DEPENDENCIES += udev

define XENOMAI_INSTALL_UDEV_RULES
	if test -d $(TARGET_DIR)/etc/udev/rules.d ; then \
		for f in $(@D)/ksrc/nucleus/udev/*.rules ; do \
			cp $$f $(TARGET_DIR)/etc/udev/rules.d/ ; \
		done ; \
	fi;
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_INSTALL_UDEV_RULES
endif # udev

define XENOMAI_REMOVE_UDEV_RULES
	if test -d $(TARGET_DIR)/etc/udev/rules.d ; then \
		for f in $(@D)/ksrc/nucleus/udev/*.rules ; do \
			rm -f $(TARGET_DIR)/etc/udev/rules.d/$$f ; \
		done ; \
	fi;
endef

XENOMAI_POST_UNINSTALL_TARGET_HOOKS += XENOMAI_REMOVE_UDEV_RULES

$(eval $(call AUTOTARGETS,package,xenomai))
