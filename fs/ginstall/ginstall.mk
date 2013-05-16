ifeq ($(BR2_arm),y)
include fs/ginstall/gflt200/*.mk
else
include fs/ginstall/gftv100/*.mk
endif
