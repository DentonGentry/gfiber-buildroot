# Until we add a proper package
GOOGLE_JAVA_HOME=/usr/local/buildtools/java/jdk
ifeq ($(BR2_PACKAGE_BRUNO),y)
BCM_MAKEFLAGS += BRUNO_PLATFORM=y
ifeq ($(BR2_PACKAGE_BRUNO_GFHD100),y)
BCM_MAKEFLAGS += BRUNO_PLATFORM_GFHD100=y
endif
endif
