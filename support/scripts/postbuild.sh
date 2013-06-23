#!/bin/sh
set -x
TARGET_DIR=$1
TARGET_SKELETON=$2
PLATFORM_SUFFIX=$3
PROD=$4
BINARIES_DIR=$TARGET_DIR/../images

# Some skeleton files are overwritten by installed packages. Recover them to
# the customized skeleton files.
support/scripts/copy-skeleton.sh "$TARGET_DIR" "$TARGET_SKELETON" "$PLATFORM_SUFFIX"

# Generate /etc/manifest, /etc/version, /etc/softwaredate
repo --no-pager manifest -r -o "$TARGET_DIR/etc/manifest"
#TODO(apenwarr): 'git describe' should use all projects.
#  Right now it only uses buildroot.  I have a plan for this
#  involving git submodules, just don't want to change too much
#  in this code all at once.  This should work for now.
echo -n $(git describe --match=''"$PLATFORM_SUFFIX"'-*') \
  >"$TARGET_DIR/etc/version" 2>/dev/null
if [ "$PROD" != "y" ]; then
  (echo -n '-'; whoami | cut -c1-2) >>$TARGET_DIR/etc/version;
fi
cp "$TARGET_DIR/etc/version" "$BINARIES_DIR/version"
(d="$(git log --date=iso --pretty=%ad -1)"; date +%s --date="$d"; echo "$d") \
  >$TARGET_DIR/etc/softwaredate

# Installer support for VFAT platforms (and harmless elsewhere)
mkdir -p $TARGET_DIR/install
