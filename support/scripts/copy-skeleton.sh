#!/bin/sh
set -e
TARGET_DIR=$1
TARGET_SKELETON=$2
PLATFORM_SUFFIX=$3

if [ -d "$TARGET_SKELETON" ]; then \
  if [ "$PLATFORM_SUFFIX" != "" ]; then
    find "$TARGET_SKELETON" ! \( -type d -name CVS -o -name .svn -o  -type f \( -name .empty -o -name .gitignore -o -name '*~' \) \) |
        sort | while read line; do
      ORIG_TARGET_FILE=$(echo $line | sed 's#'"$TARGET_SKELETON"'#'"$TARGET_DIR"'#')
      NEW_TARGET_FILE=$(echo $ORIG_TARGET_FILE | sed -Ee 's#.platform_'"$PLATFORM_SUFFIX"'(/|$)#\1#g')
      PLATFORM_SUFFIX_REMOVED=$(echo $NEW_TARGET_FILE | sed -Ee 's#.platform_[^/]*(/|$)#\1#g')
      if [ "$NEW_TARGET_FILE" = "$PLATFORM_SUFFIX_REMOVED" ]; then
        if [ -h "$line" ]; then
          cp -dfT --preserve=all "$line" "$NEW_TARGET_FILE"
        elif [ -d "$line" ]; then
          [ ! -e "$NEW_TARGET_FILE" ] && mkdir -p "$NEW_TARGET_FILE" &&
          touch --reference="$line" "$NEW_TARGET_FILE" &&
          chmod --reference="$line" "$NEW_TARGET_FILE"
        else
          cp -alf "$line" "$NEW_TARGET_FILE"
        fi
      fi
    done
  else
    cp -alf "$TARGET_SKELETON/." "$TARGET_DIR/"
  fi
fi

