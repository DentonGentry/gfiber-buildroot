SIMPLERAMFS_FIRMWARE_SITE=repo://vendor/firmware

define SIMPLERAMFS_FIRMWARE_INSTALL_TARGET_CMDS
	# BR2_* strings contain wrapper quotes; remove them using the $tmp
	# assignment, so that wildcards can work.
	set -e; \
	tmp=$(BR2_PACKAGE_SIMPLERAMFS_FIRMWARE_FILENAMES); \
	for d in $$tmp; do \
	  for dd in $(@D)/$$d; do \
	    dir=$$(dirname "$(TARGET_DIR)/lib/firmware/$$d"); \
	    mkdir -p "$$dir"; \
	    cp "$$dd" "$$dir/"; \
	  done; \
	done
endef

$(eval $(call GENTARGETS))
