# Returns true if the string $1 contains the string $2.
contains() {
  case "$1" in
    *"$2"*)
      return 0
  esac
  return 1
}


log()
{
  echo "$*" >&2
}


signal_failure() {
  # The address we signal back to the bootloader is the
  # same for 7425 and 7429 chips but different for 7252.
  # The register we're using is the last word in
  # SYSTEM_DATA_RAMi_ARRAY_BASE.
  read x y armplatform platform junk </proc/cpuinfo
  if contains "$platform" "BCM742"; then
    REG_FAILURE_COUNT="0x104083FC"
  fi

  if [ -n "$REG_FAILURE_COUNT" ]; then
    devmem $REG_FAILURE_COUNT 32 1
  fi
}


die()
{
  log "$*"
  log "FATAL ERROR DURING SIMPLERAMFS BOOT: rebooting immediately."

  # rebooting from the alternate boot image
  signal_failure
  exit 1  # kernel will auto-reboot if process#1 dies
}


read_cmdline()
{
  ROOTDEV=
  ROOTFSTYPE=
  NFSROOT=
  UBI_MTD=
  INIT=
  DEBUG=
  IP=

  set $(cat /proc/cmdline)
  for i in "$@"; do
    key=${i%%=*}
    value=${i#*=}
    case "$key" in
      root) ROOTDEV=$value ;;
      rootfstype) ROOTFSTYPE=$value ;;
      nfsroot) NFSROOT=$value ;;
      ubi.mtd) UBI_MTD=$value ;;
      init) INIT=$value ;;
      debug|login) DEBUG=1 ;;
      ip) IP=$value ;;
    esac
  done
}
