#!/bin/bash
# Useful shell utility functions.

# Atomically rewrite a file by writing to a temp file and then renaming it.
# Only rewrites the file if it's different from before.  This helps avoid
# unnecessary flash churn.
atomic() {
  local filename="$1" newval="$2"
  shift

  if [ ! -e $filename ] || [ "$(cat $filename)" != "$newval" ]; then
    rm -f $filename.new
    echo "$@" >$filename.new
    mv $filename.new $filename
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
  [ -n "$1" ] && [ -z "${1##*$2*}" ]
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
    babysit 30 soft_rc -i $RC_PIPE 2>&1 | logos softrc &
  fi
}

rc_pipe_deinit() {
    pkillwait -x soft_rc
    rm -f $RC_PIPE
}

start_sagesrv() {
  LD_LIBRARY_PATH=/app/sage:/app/sage/lib
  # Start up native streaming server
  VIDEO_UID=$(id -u video)
  VIDEO_GID=$(id -g video)
  babysit 10 \
  alivemonitor /tmp/sagesrvalive 80 10 120 \
  /app/sage/sagesrv -l6 -m5 \
      -U $VIDEO_UID -G $VIDEO_GID -f 2>&1 | logos z 0 20000000 &
}

stop_sagesrv() {
  pkillwait -f '(babysit.*)(sagesrv)'
  pkillwait -x 'sagesrv'
  pkillwait -f '(alivemonitor.*)(sagesrv)'
}

setup_ads() {
  mkdir -p /rw/sagesrv
  chmod 770 /rw/sagesrv
  chown video.video /rw/sagesrv
  chown video.video /rw/sagesrv/*
}

setup_adloader() {
  mkdir -p /var/media/ads /var/media/ads/contracts /var/media/ads/metadata
  chmod 770 /var/media/ads /var/media/ads/contracts /var/media/ads/metadata
  chown video.video /var/media/ads /var/media/ads/* /var/media/ads/contracts/* \
    /var/media/ads/metadata/*
}

start_adloader() {
  setup_adloader
  if [ -e /app/sage/adloader ]; then
    VIDEO_UID=$(id -u video)
    VIDEO_GID=$(id -g video)
    babysit 10 ionice -c 3 -n 7 /app/sage/adloader -U $VIDEO_UID -G $VIDEO_GID 2>&1 \
      | logos adsld 0 20000000 &
  fi
}

stop_adloader() {
  if [ -e /app/sage/adloader ]; then
    pkillwait -f '(babysit.*)(adloader)'
    pkillwait -x 'adloader'
    pkillwait -f '(alivemonitor.*)(adloader)'
  fi
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

