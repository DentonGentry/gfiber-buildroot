#!/bin/sh

# 3 modes:
#  1: PRODUCTION_UNIT=0: mfg mode (1st boot in factory)
#  2: PRODUCTION_UNIT unset: "factory reset" mode
#  3: PRODUCTION_UNIT=1: normal mode

# press and hold button 10+sec to go to #2
# #2 -> #3 after 5 minutes

# Processes the output of the reset click handler.
# <1s click means: show provisioning info
# 1-9s click means: reboot device
# 10+s:  Remove PRODUCTION_MODE and reboot (factory reset)

DISABLE_FILE="/tmp/gpio/disable"

while read -r type timer
do
  line="$type$timer"
  echo "$0: $line received"

  if [ "$type" = buttondown ]; then
    # stop gpio-mailbox from writing to leds
    touch $DISABLE_FILE
  fi

  case "$line" in
    buttondown0)
      # Set the led to solid red.
      echo none >/sys/class/leds/sys-red/trigger
      echo none >/sys/class/leds/sys-blue/trigger
      echo 0 >/sys/class/leds/sys-blue/brightness
      echo 1 >/sys/class/leds/sys-red/brightness
      ;;
    buttondown[1-9]*)
      echo 0 >/sys/class/leds/sys-red/brightness
      sleep .2
      echo 1 >/sys/class/leds/sys-red/brightness
      ;;
    click0)
      # show provision type
      # TODO(edjames)
      echo 0 >/sys/class/leds/sys-red/brightness
      echo 0 >/sys/class/leds/sys-blue/brightness
      for n in 0 100 0 100 0 100 0; do
        echo $n >/sys/class/leds/sys-red/brightness
        sleep .5
      done
      ;;
    click[1-9])
      echo "$0: rebooting"
      reboot
      ;;
    click10 | click*)
      echo "$0: click10 received."
      # 10 quick pulses indicates reset succeeded
      echo 0 >/sys/class/leds/sys-red/brightness
      echo 0 >/sys/class/leds/sys-blue/brightness
      for n in $(seq 10); do
        echo 0 >/sys/class/leds/sys-red/brightness
        sleep .1
        echo 100 >/sys/class/leds/sys-red/brightness
        sleep .1
      done
      sysvar_cmd -r PRODUCTION_UNIT
      reboot
      ;;
    *)
      ;;
  esac

  if [ "$type" = click ]; then
    # restore gpio-mailbox
    rm -f $DISABLE_FILE
  fi
done

echo "exiting"
