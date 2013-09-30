#!/bin/sh

# Processes the output of the reset click handler.
# 0-2s click means: reboot device
# 2-10s click means:
#   If this device is in mfg mode, start dropbear
#   else reboot
# More than 10s:  Remove PRODUCTION_MODE and reboot.

while read -r line
do
	case "$line" in
		buttondown)
			# Set the led to solid red.
			echo none >/sys/class/leds/sys-red/trigger
			echo none >/sys/class/leds/sys-blue/trigger
			echo 0 >/sys/class/leds/sys-red/brightness
			echo 0 >/sys/class/leds/sys-blue/brightness
			echo 1 >/sys/class/leds/sys-red/brightness
			;;
		click0)
			echo "click0 received"
			reboot
			;;
		click2)
			echo "click 2 received."
			if [ ! `sysvar_cmd -g PRODUCTION_UNIT` ]; then
				echo "Not a production unit."
				if [ ! -e /tmp/DEBUG ]; then
					echo "tmpdebug does not exist, starting dropbear"
					echo 1 >/tmp/DEBUG
					/etc/init.d/S50dropbear start
					rm /tmp/DEBUG
				fi
			else
				echo "rebooting"
				reboot
			fi
			;;
		click10)
			echo "click10 received."
			sysvar_cmd -r PRODUCTION_UNIT
			reboot
			;;
		*)
			;;
	esac
done

echo "exiting"
