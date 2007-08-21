######################################################################
#
# Check buildroot dependencies and bail out if the user's
# system is judged to be lacking....
#
######################################################################

dependencies: host-sed host-lzma
	@HOSTCC="$(firstword $(HOSTCC))" MAKE="$(MAKE)" \
		HOST_SED_DIR="$(HOST_SED_DIR)" \
		$(TOPDIR)/toolchain/dependencies/dependencies.sh

dependencies-source:

dependencies-clean:
	rm -f $(SSTRIP_TARGET)

dependencies-dirclean:
	true

#############################################################
#
# Toplevel Makefile options
#
#############################################################
.PHONY: dependencies

