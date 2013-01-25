ifeq ($(BR2_PACKAGE_PRISM),y)
include fs/ginstall/gflt200/*.mk
else
include fs/ginstall/gftv100/*.mk
endif
