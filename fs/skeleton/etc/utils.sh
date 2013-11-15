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
  WIFI_IF="eth2"
  [ -f "/sys/class/net/$WIFI_IF/address" ] && runnable wl
}


# Returns true if the string $1 starts with the string $2.
startswith() {
  [ "${1#$2}" != "$1" ]
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
    babysit 30 soft_rc -i $RC_PIPE 2>&1 | logos soft_rc &
  fi
}

rc_pipe_deinit() {
    pkillwait -x soft_rc
    rm -f $RC_PIPE
}

start_sagesrv() {
  LD_LIBRARY_PATH=/app/sage:/app/sage/lib
  # Start up native streaming server
  SAGESRV_UID=$(id -u video)
  SAGESRV_GID=$(id -g video)
  babysit 10 alivemonitor /tmp/sagesrvalive 80 10 120 /app/sage/sagesrv -l6 -m5 \
    -U $SAGESRV_UID -G $SAGESRV_GID -f 2>&1 | logos z 0 20000000 &
}

stop_sagesrv() {
  pkillwait -f '(babysit.*)(sagesrv)'
  pkillwait -x 'sagesrv'
  pkillwait -f '(alivemonitor.*)(sagesrv)'
}
