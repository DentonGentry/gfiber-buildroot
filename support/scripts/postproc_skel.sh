#!/bin/sh
set -x
TARGET_DIR=$1
TARGET_SKELETON=$2
PLATFORM_SUFFIX=$3

# Some skeleton files are overwritten by installed packages. Recover them to
# the customized skeleton files.
cp -alf "$TARGET_SKELETON/." "$TARGET_DIR/"
if [ "$PLATFORM_SUFFIX" != "" ]; then
  find "$TARGET_SKELETON" -name "*.platform_*" | sort | while read line; do
    ORIG_TARGET_FILE=$(echo $line | sed 's#'"$TARGET_SKELETON"'#'"$TARGET_DIR"'#')
    NEW_TARGET_FILE=$(echo $ORIG_TARGET_FILE | sed 's#.platform_'"$PLATFORM_SUFFIX"'##g')
    if [ -d $ORIG_TARGET_FILE ]; then
      rm -rf "$ORIG_TARGET_FILE"
      mkdir -p "$NEW_TARGET_FILE"
    else
      rm -rf "$ORIG_TARGET_FILE"
      if [ "$ORIG_TARGET_FILE" != "$NEW_TARGET_FILE" ]; then
        cp -alf "$line" "$NEW_TARGET_FILE"
      fi
    fi
  done
fi
