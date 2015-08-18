#!/bin/sh
set -e
TARGET_DIR=$1
TARGET_SKELETON=$2
PLATFORM_PREFIX=$3

# Returns true if the string $1 starts with the string $2.
startswith() {
  [ "${1#"$2"}" != "$1" ]
}

case "$PLATFORM_PREFIX" in
  gflt*)
    PLATFORM_SUFFIX=gfiberlt
    ;;
  gfsc*)
    PLATFORM_SUFFIX=gfibersc
    ;;
  gfmn*)
    PLATFORM_SUFFIX=gfiberwc
    ;;
  gftv*|gfrg*|gfibertv|kvm|gjcb*|gfex*|gfch*)
    PLATFORM_SUFFIX=gfibertv
    ;;
  *)
    echo "$0 exiting, bad platform prefix: '$PLATFORM_PREFIX'"
    exit 1
    ;;
esac

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
          cp -f --preserve=all "$line" "$NEW_TARGET_FILE"
        fi
      fi
    done
  else
    cp -f --preserve=all "$TARGET_SKELETON/." "$TARGET_DIR/"
  fi
fi

