log()
{
  echo "$*" >&2
}

REG_FAILURE_COUNT="0x104083FC"

signal_failure() {
  devmem $REG_FAILURE_COUNT 32 1
}


die()
{
  log "$*"
  log "FATAL ERROR DURING SIMPLERAMFS BOOT: rebooting immediately."

  # rebooting from the alternate boot image
  signal_failure
  reboot
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
