#!/bin/sh

echo "$(serial)"
echo "$(cat /tmp/platform)"

if [ -e /tmp/gpio/ledcontrol/secure_boot ]; then
  echo "CPU is locked"
else
  echo "CPU is unlocked"
fi

if [ "$(kernopt debug)" = 1 ] || [ "$(kernopt login)" = 1 ]; then
  echo "bootloader serial port enabled"
elif [ -e /tmp/DEBUG ]; then
  echo "Linux serial port enabled"
else
  echo "Serial port disabled"
fi

if [ -e /tmp/DEBUG ]; then
  echo "DEBUG enabled"
else
  echo "DEBUG disabled"
fi

if [ "$(kernopt factory)" = 1 ]; then
  echo "Factory=1 enabled"
else
  echo "Factory=1 disabled"
fi

if [ "$(kernopt wifical)" = 1 ]; then
  echo "Wifi calibration enabled"
else
  echo "Wifi calibration disabled"
fi
