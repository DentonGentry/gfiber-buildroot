#!/bin/sh
# Useful shell utility functions.

# Atomically rewrite a file by writing to a temp file and then renaming it.
# Only rewrites the file if it's different from before.  This helps avoid
# unnecessary flash churn.
atomic() {
  local filename="$1" newval="$2"
  shift

  if [ ! -e "$filename" ] || [ "$(cat "$filename")" != "$newval" ]; then
    # fsync after writing the temp file to avoid the potential for ending up
    # with a zero length file at $filename on ext4 partitions due to ext4's
    # delayed allocation.
    rm -f "$filename.new"
    echo "$@" >"$filename.new"
    fsync "$filename.new"
    mv "$filename.new" "$filename"
  fi
}


# Returns true if the system has wifi.
has_wifi() {
  for d in /sys/class/net/wlan*/address; do
    [ -f "$d" ] && return 0
  done
  if runnable wl; then
    # on boxes with wl, wifi is eth2
    [ -f "/sys/class/net/eth2/address" ] && return 0
  fi
  return 1
}


# Returns true if the string $1 starts with the string $2.
startswith() {
  [ "${1#"$2"}" != "$1" ]
}


# Returns true if the string $1 ends with the string $2.
endswith() {
  [ "${1%$2}" != "$1" ]
}


# Returns true if the string $1 contains the string $2.
contains() {
  case "$1" in
  *"$2"*)
    return 0
  esac
  return 1
}


# Checks if the string $1 is appears in file $2
filecontains() {
  grep "$1" $2 >/dev/null
  [ $? -eq 0 ]
}


export RC_PIPE=/tmp/rc_pipe
rc_pipe_init() {
  if is-tv-box; then
    [ -e $RC_PIPE ] && rm $RC_PIPE
    mknod $RC_PIPE p
    chown root.video $RC_PIPE
    chmod 620 $RC_PIPE # give sage write permissions
    nice babysit 30 soft_rc -i $RC_PIPE 2>&1 | logos softrc &
  fi
}


rc_pipe_deinit() {
    pkillwait -x soft_rc
    rm -f $RC_PIPE
}


setup_mcastcapture_settings() {
  mkdir -p /rw/sagesrv
  chmod 770 /rw/sagesrv
  chown video.video /rw/sagesrv
  chown video.video /rw/sagesrv/*
}


start_sagesrv() {
  setup_mcastcapture_settings
  LD_LIBRARY_PATH=/app/sage:/app/sage/lib
  # Start up native streaming server
  VIDEO_UID=$(id -u video)
  VIDEO_GID=$(id -g video)
  babysit 10 \
  alivemonitor /tmp/sagesrvalive 80 10 120 \
  /app/sage/sagesrv -l6 -m5 -U $VIDEO_UID -G $VIDEO_GID -f 2>&1 \
    | logos z 0 20000000 &
}


stop_sagesrv() {
  pkillwait -f '([b]abysit.*)(sagesrv)'
  pkillwait -x 'sagesrv'
  pkillwait -f '([a]livemonitor.*)(sagesrv)'
}


setup_ads() {
  setup_mcastcapture_settings
  mkdir -p /var/media/ads
  chmod 770 /var/media/ads
  chown video.video /var/media/ads
  chown video.video /var/media/ads/*
  mkdir -p /rw/ads/database
  mkdir -p /rw/ads/contracts
  mkdir -p /rw/ads/cms
  chmod 770 /rw/ads
  chmod 770 /rw/ads/database
  chmod 770 /rw/ads/contracts
  chmod 770 /rw/ads/cms
  chown -R video.video /rw/ads
}


start_adsmgr() {
  setup_ads
  VIDEO_UID=$(id -u video)
  VIDEO_GID=$(id -g video)
  # Start up native ads manager
  babysit 60 \
  alivemonitor /tmp/adsmgralive 80 10 120 \
  /app/sage/adsmgr -U $VIDEO_UID -G $VIDEO_GID 2>&1 | logos ads 0 20000000 &
}


stop_adsmgr() {
  pkillwait -f '([b]abysit.*)(adsmgr)'
  pkillwait -x 'adsmgr'
  pkillwait -f '([a]livemonitor.*)(adsmgr)'
}


start_adscale() {
  setup_mcastcapture_settings
  VIDEO_UID=$(id -u video)
  VIDEO_GID=$(id -g video)
  # Start up native adscale manager
  babysit 60 \
  alivemonitor /tmp/adscalealive 80 10 120 \
  /app/sage/adscale -U $VIDEO_UID -G $VIDEO_GID 2>&1 | logos adscale 0 20000000 &
}


stop_adscale() {
  pkillwait -f '([b]abysit.*)(adscale)'
  pkillwait -x 'adscale'
  pkillwait -f '([a]livemonitor.*)(adscale)'
}


mac_addr_increment() {
  echo "$1" | (
    IFS=: read m1 m2 m3 m4 m5 m6
    m6d=$(printf "%d" "0x$m6")
    m6d=$(($m6d + $2))
    if [ $m6d -ge 256 ]; then
      m6d=$(($m6d - 256))
      m5d=$(printf "%d" "0x$m5")
      m5d=$(($m5d + 1))
      if [ $m5d -ge 256 ]; then
        m5d=$(($m5d - 256))
        m4d=$(printf "%d" "0x$m4")
        m4d=$(($m4d + 1))
        if [ $m4d -ge 256 ]; then
          m4d=$(($m4d - 256))
        fi
        m4=$(printf "%02x" $m4d)
      fi
      m5=$(printf "%02x" $m5d)
    fi
    m6=$(printf "%02x" $m6d)
    echo "$m1:$m2:$m3:$m4:$m5:$m6"
  )
}


# set the locally administered bit on the input mac address and return the
# result (see http://en.wikipedia.org/wiki/MAC_address)
get_locally_administered_mac_addr() {
  echo $1 | {
    IFS=":" read m1 m2 m3 m4 m5 m6
    m1="0x${m1}"
    m1=$((m1 | 0x02))
    printf '%02x:%s:%s:%s:%s:%s\n' $m1 $m2 $m3 $m4 $m5 $m6
  }
}


get_mac_addr_for_interface() {
  cat "/sys/class/net/$1/address" 2> /dev/null
}


find_phy_for_interface() {
  local interface="$1"
  local phy_name=
  iw dev | while read a b junk; do
    if startswith "$a" "phy"; then
      phy_name="$a"
    elif [ "$a" = Interface -a "$b" = "$interface" ]; then
      echo "phy${phy_name#phy\#}"
      break
    fi
  done
}

# Returns true if the given experiment is currently active.
experiment() {
  local expname="$1"
  if [ ! -e "/tmp/experiments/$expname.available" ]; then
    echo "Warning: Experiment '$expname' not registered." >&2
    return 2
  elif [ -e "/config/experiments/$expname.active" ]; then
    echo "Experiment '$expname' active." >&2
    return 0
  else
    return 1
  fi
}

find_sata_blkdev() {
  local dev_node result=

  for dev_node in /dev/sd?; do
    [ -b "$dev_node" ] || continue

    local blkdev=${dev_node#/dev/}
    local dev_path=$(realpath "/sys/block/$blkdev/device")
    if [ "${dev_path#*usb}" = "$dev_path" ]; then
      result="$dev_node"
      break
    fi
  done

  [ -n "$result" ] && echo "$result"
}

find_usb_blkdev() {
  local dev_node result=

  for dev_node in /dev/sd?; do
    [ -b "$dev_node" ] || continue

    local blkdev=${dev_node#/dev/}
    local dev_path=$(realpath "/sys/block/$blkdev/device")
    if contains "$dev_path" "usb"; then
      result="$dev_node"
      break
    fi
  done

  [ -n "$result" ] && echo "$result"
}

interface_exists() {
  [ -e "/sys/class/net/$1" ]
}

is_quantenna_interface() {
  # Check for "$1 " to prevent "wlanX" from matching "wlanX_portal".
  filecontains "$1 " /sys/class/net/quantenna/vlan >/dev/null 2>&1
}

ip46tables() {
  local x y
  iptables "$@"; x=$?
  ip6tables "$@"; y=$?
  return $(($x | $y))
}

# Used by GFSC100. Starts an app with babysit (specified delay) and also logs.
babysit_start() {
  local delay="$1"
  local app="$2"
  local binary="$3"
  local flags="$4"
  if [ -e /tmp/DEBUG ]; then
    # Developer devices save application logs.
    mkdir -p /var/media/applog
    echo "=== $app started ===" >> /var/media/applog/$app
    flags="$flags -v=2"
    babysit $delay $binary $flags 2>&1 | tee -a /var/media/applog/$app | logos $app &
  else
    babysit $delay $binary $flags 2>&1 | logos $app &
  fi
}

platform_megs_ram() {
  n=$(grep MemTotal /proc/meminfo | sed -e 's/MemTotal: *//' -e 's/ kB$//')
  echo $((n / 1024))
}

# Determine whether I2C IO expanders are present based on platform and HW Ver.
# returns 1 if IO expanders are present, 0 if not.
has_i2c_expander() {
  platform=$(cat /etc/platform)
  if [ "$platform" = "GFCH100" ]; then
    if [ -f /etc/hw_ver ]; then
      local CHIMERA_1_2A_HW_VER
      CHIMERA_1_2A_HW_VER=2
      hwver=$(cat /etc/hw_ver)
      if [ $hwver = $CHIMERA_1_2A_HW_VER ]; then
        return 1
      fi
    fi
  fi
  return 0
}

num_sfp_ports() {
  platform=$(cat /etc/platform)
  if [ "$platform" = "GFCH100" ]; then
    if [ -f /etc/hw_ver ]; then
      local CHIMERA_1_2A_HW_VER
      CHIMERA_1_2A_HW_VER=2
      hwver=$(cat /etc/hw_ver)
      if [ $hwver -ge $CHIMERA_1_2A_HW_VER ]; then
        return 2
      fi
    fi
  fi
  return 1
}

set_mac_from_hnvram() {
  local DEV="$1"
  local VAR_NAME="$2"
  if [ -h /sys/class/net/$DEV ]; then
    local addr="$(hnvram -qr "$VAR_NAME")"
    if [ -n "$addr" ]; then
      if is_quantenna_interface $DEV; then
        addr="$(get_locally_administered_mac_addr "$addr")"
      fi
      echo "Setting $DEV mac address to $addr"
      ip link set dev $DEV down
      ip link set dev $DEV address "$addr"
      ip link set dev $DEV up
    else
      echo "$DEV: sysvar $VAR_NAME not found"
    fi
  fi
}
