#
# configuration for diagnostic scripts
#

#
# general configs here
#

dram_memory=500M		# how much memory to test


#
# platform specific configs follow
#
PLATFORM_NAME=$(hnvram -qr PLATFORM_NAME)
case "$PLATFORM_NAME" in
  GFHD100)
    ;;
  GFMS100)
    ;;
  GFRG200)
    ;;
  *)
    echo "$0: WARNING: unknown platform '$PLATFORM_NAME', using defaults" 1>&2
    ;;
esac
