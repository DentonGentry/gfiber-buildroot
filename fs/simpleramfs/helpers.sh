log()
{
  echo "$*" >&2
}


die()
{
  log "$*"
  log "FATAL ERROR DURING SIMPLERAMFS BOOT: rebooting immediately."

  # we didn't set the "verified" flag in S99readallfiles, so CFE should know
  # this and try booting the alternate boot image.
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
    esac
  done
}
