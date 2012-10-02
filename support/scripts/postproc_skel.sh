#!/bin/sh
set -x
TARGET_SKELETON=$1
TARGET_DIR=$2
PLATFORM_SUFFIX=$3

if [ "$PLATFORM_SUFFIX" != "" ]; then
	find $TARGET_SKELETON -name "*.platform_*" | sort | while read line
	do
		ORIG_TARGET_FILE=${line/$TARGET_SKELETON/$TARGET_DIR}
		rm -rf "$ORIG_TARGET_FILE"
		NEW_TARGET_FILE=${ORIG_TARGET_FILE//.platform_$PLATFORM_SUFFIX}
		if [ "$ORIG_TARGET_FILE" != "$NEW_TARGET_FILE" ]; then
			cp -alf "$line" "$NEW_TARGET_FILE"
		fi
	done
fi
