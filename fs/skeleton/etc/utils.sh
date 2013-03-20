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
  test -f "/sys/class/net/$WIFI_IF/address"
}


# Returns true if the string $1 starts with the string $2.
startswith() {
  [ "${1#$2}" != "$1" ]
}


# Returns true if the string $1 ends with the string $2.
endswith() {
  [ "${1%$2}" != "$1" ]
}


# Checks if the string $1 is appears in file $2
filecontains() {
  grep "$1" $2 >/dev/null
  [ $? -eq 0 ]
}
