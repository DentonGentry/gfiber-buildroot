#############################################################
#
# golang 1.6.2 - https://go.googlesource.com/go/+/go1.6.2
#
#############################################################
GOLANG_VERSION = 57e459e02b4b01567f92542f92cd9afde209e193
GOLANG_SITE = https://go.googlesource.com/go
GOLANG_SITE_METHOD = git
GOLANG_DEPENDENCIES = host-golang_bootstrap

GOLANG_RELEASE = 1.6.2
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
GOLANG_ENV = PATH=$(TARGET_PATH) GOROOT=$(GOLANG_GOROOT) GOPATH=$(BUILD_DIR)/go_pkgs \
	GOARCH=$(GOLANG_GOARCH) CC=$(TARGET_CC_NOCCACHE) CXX=$(TARGET_CXX_NOCCACHE)

HOST_GOLANG_ENV = PATH=$(TARGET_PATH) GOROOT=$(GOLANG_GOROOT) GOPATH=$(BUILD_DIR)/go_pkgs \
	GOARCH= CC=$(HOSTCC_NOCCACHE) CXX=$(HOSTCXX_NOCCACHE) CGO_ENABLED=$(GOLANG_CGO_ENABLED)

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
	GOROOT_BOOTSTRAP=$(GOLANG_BOOTSTRAP_GOROOT) \
	CC_FOR_TARGET="$(notdir $(TARGET_CC_NOCCACHE))" \
	CXX_FOR_TARGET="$(notdir $(TARGET_CXX_NOCCACHE))" \
	./make.bash
endef

define HOST_GOLANG_INSTALL_CMDS
	$(INSTALL) -d -m 0755 "$(GOLANG_GOROOT)"
	cp -a "$(@D)"/* "$(GOLANG_GOROOT)/"
	ln -sfT "../lib/golang-$(GOLANG_RELEASE)/bin/go" "$(HOST_DIR)/usr/bin/go"
	ln -sfT "../lib/golang-$(GOLANG_RELEASE)/bin/gofmt" "$(HOST_DIR)/usr/bin/gofmt"
endef

define HOST_GOLANG_CLEAN_CMDS
	cd "$(@D)/src" && PATH=$(HOST_DIR)/usr/bin:$$PATH ./clean.bash
endef

$(eval $(call GENTARGETS,host))
