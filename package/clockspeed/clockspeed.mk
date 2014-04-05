CLOCKSPEED_VERSION = 0.62
CLOCKSPEED_SITE =  http://cr.yp.to/clockspeed
CLOCKSPEED_SOURCE = clockspeed-${CLOCKSPEED_VERSION}.tar.gz
CLOCKSPEED_DEPENDENCIES = 

define CLOCKSPEED_CONFIGURE_CMDS
	echo "$(TARGET_CC)" >$(@D)/conf-cc
	echo "$(TARGET_CC) -lrt -s" >$(@D)/conf-ld
	echo "/tmp/clockspeed" >$(@D)/conf-home
endef

define CLOCKSPEED_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define CLOCKSPEED_INSTALL_TARGET_CMDS
	cd $(@D) && \
	cp clockadd clockspeed clockview sntpclock taiclock taiclockd \
		$(TARGET_DIR)/usr/bin
endef

$(eval $(call GENTARGETS))
