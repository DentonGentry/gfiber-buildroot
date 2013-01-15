#############################################################
#
# i2c-tools
#
#############################################################

I2C_TOOLS_VERSION = 3.1.0
I2C_TOOLS_SOURCE = i2c-tools-$(I2C_TOOLS_VERSION).tar.bz2
I2C_TOOLS_SITE = http://dl.lm-sensors.org/i2c-tools/releases
I2C_TOOLS_DEPENDENCIES=host-python python

# py-smbus is part of the i2c-tools but not included in the build. The build
# rule for py-smbus is only applicable for host==target environment. To avoid
# passing all environmental variables to the top level, the python build is
# invoked separately instead of putting EXTRA="py-smbus".
define I2C_TOOLS_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
	(cd $(@D)/py-smbus && PYTHONPATH=$(TARGET_PYTHONPATH) \
		   CC="$(TARGET_CC)" \
		   LD="$(TARGET_LD)" \
		   LDSHARED="$(TARGET_CC) -shared" \
		   CFLAGS="$(TARGET_CFLAGS) -fPIC -I$(@D)/include \
		   -I$(STAGING_DIR)/usr/include/python2.7" \
		   $(HOST_DIR)/usr/bin/python setup.py build)
endef

define I2C_TOOLS_INSTALL_TARGET_CMDS
	for i in i2cdump i2cget i2cset i2cdetect; \
	do \
		$(INSTALL) -m 755 -D $(@D)/tools/$$i $(TARGET_DIR)/usr/bin/$$i; \
	done
	(cd $(@D)/py-smbus && \
		PYTHONPATH=$(TARGET_PYTHONPATH) \
		$(HOST_DIR)/usr/bin/python setup.py install \
		--prefix=$(TARGET_DIR)/usr)
endef

$(eval $(call GENTARGETS))
