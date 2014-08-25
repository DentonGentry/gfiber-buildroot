#############################################################
#
# gfrm200 (remote control firmware images for gftv* builds)
#
#############################################################
GOOGLE_GFRM200_SITE = repo://loader-bin

GOOGLE_GFRM200_SDIR = $(@D)/philips/gfrm200
GOOGLE_GFRM200_TDIR = $(TARGET_DIR)/etc/remote
GOOGLE_GFRM200_LINKS = gfrm200.gp.bin gfrm200.ti.bin

# sample remote GP firmware name: RC1534059_OAD_GP_V0011.bin
# sample remote TI firmware name: RC1534059_OAD_TI_V0049.bin
# symlinks gfrm200.ti.bin and gfrm200.gp.bin are used to pick current ones
 
define GOOGLE_GFRM200_INSTALL_TARGET_CMDS
	rm -rf $(GOOGLE_GFRM200_TDIR)/*.bin
	mkdir -p $(GOOGLE_GFRM200_TDIR)
	set -e; \
	for n in $(GOOGLE_GFRM200_LINKS); do \
	  md5sum $(GOOGLE_GFRM200_SDIR)/$$n; \
	  l=$$(readlink $(GOOGLE_GFRM200_SDIR)/$$n); \
	  cp $(GOOGLE_GFRM200_SDIR)/$$l $(GOOGLE_GFRM200_TDIR); \
	  ln -sf $$l $(GOOGLE_GFRM200_TDIR)/$$n; \
	  echo "creating symlink link: $$n -> $$l"; \
      	done
endef

$(eval $(call GENTARGETS))
