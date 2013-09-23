#

# run a command and exit immediately with message
# quoting of spaces might not be handled well
# calls 'cleanup' which must be defined by caller
run()
{
  echo "Running: $*"
  if ! "$@" < /dev/null; then
    error="failed: $*"
    echo "Command failed: $*"
    cleanup
    echo FAIL "$error"
    exit
  fi
}

getaddr()
{
  local if ifconfig ip
  if="$1"

  ifconfig=$(ifconfig $if || true)
  ip=${ifconfig%% mask *}
  ip=${ip##* }
  echo $ip
}

wait_for_addr()
{
  local if secs n ip
  if=$1
  secs=$2

  for n in $(seq 1 $secs); do
    ip=$(getaddr $if)
    if [ ! -z "$ip" ]; then
      break
    fi
    sleep 1
  done
  echo $ip
}

# check if nfs is using this interface
isNFS()
{
  local if nfs nfsip nfsNet ip ipNet
  if="$1"

  nfs=$(mount | grep ' nfs ' || true)
  nfsip=${nfs%%:*}
  nfsNet=${nfsip%.*}	# strip last octet from ip addr, use as network

  ip=$(getaddr $if)
  ipNet=${ip%.*}

  # check if interface is on same network as nfs server
  if [ "$nfsNet" ] && [ "$nfsNet" = "$ipNet" ]; then
    echo 1
  else
    echo 0
  fi
}

dhclient_start()
{
  dhclient -nw -1 $1
  ip=$(wait_for_addr $1 30)
  echo "dhclient_start: IP address is '$ip'"
  if [ -z "$ip" ]; then
    dhclient_stop
    return 1
  fi
}

dhclient_stop()
{
  dhclient -x $1 || echo but no matter
  killall dhclient || echo but no matter
  killall ntpd || echo but no matter
  killall babysit || echo but no matter
  killall logos || echo but no matter
}

redblueled()
{
  red=1
  blue=1
  if [ "$1" = 0 ]; then
    red=0
  fi
  if [ "$2" = 0 ]; then
    blue=0
  fi
  python $(dirname $0)/gpio_gfrg200 red=$red blue=$blue
}
