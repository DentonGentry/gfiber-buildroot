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

getfandir_gfrg200()
{
  echo /sys/bus/i2c/devices/0-004c
}

# read fan rpm from /sys/bus.  0..255
getfanrpm_gfrg200_sys()
{
  local dir
  dir=$(getfandir_gfrg200)
  cat $dir/pwm1
}

# write fan rpm to /sys/bus.  0..255
setfanrpm_gfrg200_sys()
{
  local dir
  dir=$(getfandir_gfrg200)
  echo $1 > $dir/pwm1
}

# read temps (1/2)
gettemp_gfrg200()
{
  local dir
  dir=$(getfandir_gfrg200)
  cat $dir/temp${1}_input
}

# read fan via i2c
getfanrpm_gfrg200_i2c()
{
  local hi lo hid lod rpm
  # must read in this order
  lo=$(i2cget -f -y 0 0x4c 0x46)
  hi=$(i2cget -f -y 0 0x4c 0x47)
  lod=$(printf "%d\n" $lo)
  hid=$(printf "%d\n" $hi)

  # registers return number of 90kHz ticks between tach pulses
  # see http://www.ti.com/lit/ds/symlink/lm96063.pdf
  rpm=$((5400000/($lo + $hi * 256)))
  echo $rpm
}

# write fan via i2c (0..100)
setfanrpm_gfrg200_i2c()
{
  local reg
  reg=$(percenttospeed_gfrg200_i2c $1)
  echo "setfanrpm_gfrg200_i2c: using $reg for $1% rpm" 
  i2cset -f -y 0 0x4c 0x4c $reg
}

# convert 0..100 to fan register
# if 4d is 0x17, 0x17 in 4c gives 50%. 2 * 0x17 gives 100%.  
# true for all values 0-31 of 4d
percenttospeed_gfrg200_i2c()
{
  local freqdec speed
  freqdec=$(getfanfreq_gfrg200_i2c)
  speed=$(($freqdec * 2 * $1 / 100))
  echo $speed
}

# convert 0..2xfreq to 0..100
speedtopercent_gfrg200_i2c()
{
  local freqdec reg
  freqdec=$(getfanfreq_gfrg200_i2c)
  reg=$((100 * $1 / ($freqdec * 2)))
  echo $reg
}

# get/set frequency divider
# 1..31 corresponds to 360KHz/(2*x)
getfanfreq_gfrg200_i2c()
{
  local freqhex freqdec
  freqhex=$(i2cget -f -y 0 0x4c 0x4d)
  freqdec=$(printf "%d\n" $freqhex)
  echo $freqdec
}

# 1..31
setfanfreq_gfrg200_i2c()
{
  i2cset -f -y 0 0x4c 0x4d $1
}

# get/set speed register
# 0..freq x 2
getfanspeed_gfrg200_i2c()
{
  local speedhex speeddec
  speedhex=$(i2cget -f -y 0 0x4c 0x4c)
  speeddec=$(printf "%d\n" $freqhex)
  echo $speeddec
}

# 0..freq x 2
setfanspeed_gfrg200_i2c()
{
  i2cset -f -y 0 0x4c 0x4c $1
}

# state
savefanstate_gfrg200()
{
  save_tach=$(i2cget -f -y 0 0x4c 0x03)
  save_speed=$(i2cget -f -y 0 0x4c 0x4c)
  save_freq=$(i2cget -f -y 0 0x4c 0x4d)
}

restorefanstate_gfrg200()
{
  i2cset -f -y 0 0x4c 0x04 $save_tach
  i2cset -f -y 0 0x4c 0x4c $save_speed
  i2cset -f -y 0 0x4c 0x4d $save_freq
}

enabletach_gfrg200()
{
  # turn on tachometer
  i2cset -f -y 0 0x4c 0x03 0x04
}

# near <reference> <tolerance> <value>
# verify value is within reference +/- tolerance
near()
{
  local ref rol val min max
  ref=$1
  tol=$2
  val=$3

  min=$(($ref - $tol))
  max=$(($ref + $tol))

  if [ "$val" -ge "$min" ] && [ "$val" -le "$max" ]; then
    return 0	# ok
  fi
  return 1
}
