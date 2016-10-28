#############################################################
#
# golang 1.4.2 - https://go.googlesource.com/go/+/go1.4.2
#
#############################################################
GOLANG_BOOTSTRAP_VERSION = 883bc6ed0ea815293fe6309d66f967ea60630e87
GOLANG_BOOTSTRAP_SITE = https://go.googlesource.com/go
GOLANG_BOOTSTRAP_SITE_METHOD = git

GOLANG_BOOTSTRAP_GOROOT = $(HOST_DIR)/usr/lib/golang-bootstrap

ifeq ("arm",$(BR2_ARCH))
GOLANG_BOOTSTRAP_GOARCH = arm
ifneq (,$(findstring armv7,$(BR2_GCC_TARGET_ARCH)))
GOLANG_BOOTSTRAP_GOARM = 7
else ifneq (,$(findstring armv6,$(BR2_GCC_TARGET_ARCH)))
GOLANG_BOOTSTRAP_GOARM = 6
endif
else ifeq ("i386",$(BR2_ARCH))
GOLANG_BOOTSTRAP_GOARCH = 386
else ifeq ("x86_64",$(BR2_ARCH))
GOLANG_BOOTSTRAP_GOARCH = amd64
endif

define HOST_GOLANG_BOOTSTRAP_BUILD_CMDS
	export PATH=$(TARGET_PATH) ; \
	cd "$(@D)/src" && \
	GOPATH= \
	GOROOT= \
	GOROOT_FINAL="$(GOLANG_BOOTSTRAP_GOROOT)" \
	GOOS=linux \
	GOARCH=$(GOLANG_BOOTSTRAP_GOARCH) \
	GOARM=$(GOLANG_BOOTSTRAP_GOARM) \
	CC_FOR_TARGET="$(notdir $(TARGET_CC_NOCCACHE))" \
	CXX_FOR_TARGET="$(notdir $(TARGET_CXX_NOCCACHE))" \
	./make.bash
endef

define HOST_GOLANG_BOOTSTRAP_INSTALL_CMDS
	$(INSTALL) -d -m 0755 "$(GOLANG_BOOTSTRAP_GOROOT)"
	cp -a "$(@D)"/* "$(GOLANG_BOOTSTRAP_GOROOT)/"
endef

define HOST_GOLANG_BOOTSTRAP_CLEAN_CMDS
	cd "$(@D)/src" && PATH=$(HOST_DIR)/usr/bin:$$PATH ./clean.bash
endef

$(eval $(call GENTARGETS,host))
