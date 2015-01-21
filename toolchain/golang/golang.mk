#############################################################
#
# golang 1.3.3 - https://go.googlesource.com/go/+/go1.3.3
#
#############################################################
GOLANG_VERSION = 3dbc53ae6ad4e3b93f31d35d98b38f6dda25f4ee
GOLANG_SITE = https://go.googlesource.com/go
GOLANG_SITE_METHOD = git

GOLANG_RELEASE = 1.3.3
GOLANG_GOROOT = $(HOST_DIR)/usr/lib/golang-$(GOLANG_RELEASE)

ifeq ("arm",$(BR2_ARCH))
GOLANG_GOARCH = arm
ifneq (,$(findstring armv7,$(BR2_GCC_TARGET_ARCH)))
GOLANG_GOARM = 7
else ifneq (,$(findstring armv6,$(BR2_GCC_TARGET_ARCH)))
GOLANG_GOARM = 6
endif
else ifeq ("i386",$(BR2_ARCH))
GOLANG_GOARCH = 386
else ifeq ("x86_64",$(BR2_ARCH))
GOLANG_GOARCH = amd64
endif

ifeq (y,$(BR2_TOOLCHAIN_GOLANG_CGO))
GOLANG_CGO_ENABLED = 1
endif

# Go packages should export $(GOLANG_ENV) to clear Go settings from the
# host environment.
GOLANG_ENV = PATH=$(TARGET_PATH) GOROOT=$(GOLANG_GOROOT) GOPATH= \
	GOARCH=$(GOLANG_GOARCH) CC=$(TARGET_CC_NOCCACHE) CXX=$(TARGET_CXX_NOCCACHE)

define HOST_GOLANG_BUILD_CMDS
	export PATH=$(TARGET_PATH) ; \
	cd "$(@D)/src" && \
	GOPATH= \
	GOROOT= \
	GOROOT_FINAL="$(GOLANG_GOROOT)" \
	GOOS=linux \
	GOARCH=$(GOLANG_GOARCH) \
	GOARM=$(GOLANG_GOARM) \
	CGO_ENABLED=$(GOLANG_CGO_ENABLED) \
	CC_FOR_TARGET="$(notdir $(TARGET_CC_NOCCACHE))" \
	CXX_FOR_TARGET="$(notdir $(TARGET_CXX_NOCCACHE))" \
	./make.bash
endef

define HOST_GOLANG_INSTALL_CMDS
	$(INSTALL) -d -m 0755 "$(GOLANG_GOROOT)"
	cp -a "$(@D)"/* "$(GOLANG_GOROOT)/"
	ln -sfT "../lib/golang-$(GOLANG_RELEASE)/bin/go" "$(HOST_DIR)/usr/bin/go"
endef

define HOST_GOLANG_CLEAN_CMDS
	cd "$(@D)/src" && PATH=$(HOST_DIR)/usr/bin:$$PATH ./clean.bash
endef

$(eval $(call GENTARGETS,host))
