#############################################################
#
# golang 1.7.4 - https://go.googlesource.com/go/+/go1.7.4
#
#############################################################
GOLANG_VERSION = 6b36535cf382bce845dd2d272276e7ba350b0c6b
GOLANG_SITE = https://go.googlesource.com/go
GOLANG_SITE_METHOD = git
GOLANG_DEPENDENCIES = host-golang_bootstrap

GOLANG_GOROOT = $(HOST_DIR)/usr/lib/golang

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
GOLANG_ENV = PATH=$(TARGET_PATH) \
	     GOARCH=$(GOLANG_GOARCH) \
	     GOBIN= \
	     GOEXE= \
	     GOPATH="$(BUILD_DIR)/go_pkgs" \
	     GORACE= \
	     GOROOT="$(GOLANG_GOROOT)" \
	     GOTOOLDIR= \
	     CC="$(TARGET_CC_NOCCACHE)" \
	     CXX="$(TARGET_CXX_NOCCACHE)" \
	     CGO_CFLAGS="$(TARGET_CFLAGS)" \
	     CGO_CXXFLAGS="$(TARGET_CXXFLAGS)" \
	     CGO_ENABLED="$(GOLANG_CGO_ENABLED)" \
	     CGO_LDFLAGS="$(TARGET_LDFLAGS)"

HOST_GOLANG_ENV = PATH=$(TARGET_PATH) \
		  GOARCH= \
		  GOBIN= \
		  GOEXE= \
		  GOPATH="$(BUILD_DIR)/go_pkgs" \
		  GORACE= \
		  GOROOT="$(GOLANG_GOROOT)" \
		  GOTOOLDIR= \
		  CC="$(HOSTCC_NOCCACHE)" \
		  CXX="$(HOSTCXX_NOCCACHE)" \
		  CGO_CFLAGS="$(HOST_CFLAGS)" \
		  CGO_CXXFLAGS="$(HOST_CXXFLAGS)" \
		  CGO_ENABLED="$(GOLANG_CGO_ENABLED)" \
		  CGO_LDFLAGS="$(HOST_LDFLAGS)"

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
	ln -sfT "../lib/golang/bin/go" "$(HOST_DIR)/usr/bin/go"
	ln -sfT "../lib/golang/bin/gofmt" "$(HOST_DIR)/usr/bin/gofmt"
endef

define HOST_GOLANG_CLEAN_CMDS
	cd "$(@D)/src" && PATH=$(HOST_DIR)/usr/bin:$$PATH ./clean.bash
endef

$(eval $(call GENTARGETS,host))
