GOOGLE_STYLEGUIDE_SITE=https://github.com/google/styleguide.git
GOOGLE_STYLEGUIDE_SITE_METHOD=git
GOOGLE_STYLEGUIDE_VERSION=6d3a7d8a229e189f7a5bb7c3923363356625ece5

define HOST_GOOGLE_STYLEGUIDE_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/cpplint/cpplint.py $(HOST_DIR)/usr/bin/cpplint.py
endef

$(eval $(call GENTARGETS,host))
