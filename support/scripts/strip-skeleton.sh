#!/bin/sh
set -x
TARGET_DIR=$1

if [ ! -d "$TARGET_DIR" ]; then
  echo "The target directory $TARGET_DIR does not exist."
  exit 1
fi

rm -f $TARGET_DIR/usr/lib/python2.7/encodings/cp*
rm -f $TARGET_DIR/usr/lib/python2.7/encodings/iso*
rm -f $TARGET_DIR/usr/lib/python2.7/encodings/mac_*
rm -f $TARGET_DIR/usr/lib/python2.7/encodings/palm*
rm -f $TARGET_DIR/usr/lib/python2.7/encodings/shift*
rm -f $TARGET_DIR/usr/lib/python2.7/encodings/utf_16*
rm -f $TARGET_DIR/usr/lib/python2.7/encodings/euc*
rm -f $TARGET_DIR/usr/lib/python2.7/encodings/gb*

# Remove setuptools
rm -f $TARGET_DIR/usr/lib/python2.7/site-packages/setuptools*

