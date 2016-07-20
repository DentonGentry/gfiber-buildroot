#!/bin/sh
set -x
set -e
TARGET_DIR=$1
TARGET_SKELETON=$2
PLATFORM_PREFIX=$3
PROD=$4
UNSIGNED=$5
BINARIES_DIR=$TARGET_DIR/../images

# Some skeleton files are overwritten by installed packages. Recover them to
# the customized skeleton files.
support/scripts/copy-skeleton.sh "$TARGET_DIR" "$TARGET_SKELETON" "$PLATFORM_PREFIX"

# Strip out some files from the target file system that we shouldn't need.
echo "!!!!!!!!!! Stripping $TARGET_DIR "
support/scripts/strip-skeleton.sh "$TARGET_DIR"
echo "!!!!!!!!!! DONE Stripping $TARGET_DIR "

# Generate /etc/manifest, /etc/version, /etc/softwaredate
rm -f "$TARGET_DIR/etc/manifest"
if [ -d ../.repo ]; then
  repo --no-pager manifest -r -o "$TARGET_DIR/etc/manifest"
  FORALL="repo forall -c"
elif [ -d ../.git/modules ]; then
  ( cd .. &&
    echo -n 'commitid ' &&
    git describe --no-abbrev --always
  ) >"$TARGET_DIR/etc/manifest"
  FORALL="git submodule --quiet foreach"
else
  echo "Can't find repo or git-submodules top.  Aborting." >&2
  exit 99
fi
# TODO(apenwarr): If we use git-submodules, we can just check the top level.
#   The git-submodules superproject commit id is enough to identify
#   everything about all included subprojects.  But for now, just do it
#   the same with both repo and submodules.
tagname=$(git describe)
tagabbrev=$(git describe --abbrev=0)
tree_state=$(git rev-list "$tagabbrev"..HEAD)
if [ -n "$tree_state" ]; then
  # Tree has commits since last tag, rebuild the image name
  count=$(cd .. &&
             $FORALL "git rev-list '$tagabbrev'..HEAD 2>/dev/null" |
             wc -l)
  version="$PLATFORM_PREFIX-${tagabbrev#*-}-$count-${tagname##*-}"
else
  version="$PLATFORM_PREFIX-${tagname#*-}"
fi
echo -n "$version" >"$TARGET_DIR/etc/version" 2>/dev/null

if [ "$PROD" != "y" ]; then
  echo -n "-$(whoami | cut -c1-2)" >>$TARGET_DIR/etc/version
fi
if [ "$UNSIGNED" == "y" ]; then
  echo -n '-unsigned' >>$TARGET_DIR/etc/version
fi
cp "$TARGET_DIR/etc/version" "$BINARIES_DIR/version"
(d="$(git log --date=iso --pretty=%ad -1)"; date +%s --date="$d"; echo "$d") \
  >$TARGET_DIR/etc/softwaredate

# Installer support for VFAT platforms (and harmless elsewhere)
mkdir -p $TARGET_DIR/install

# SpaceCast production build
if [ "$PLATFORM_PREFIX" = "gfsc100" -a "$PROD" = "y" ]; then
  # Disable root password login.
  sed -i 's/^root:[^:]*:/root:!:/' $TARGET_DIR/etc/passwd
  # Disable serial console.
  sed -i '/rungetty/d' $TARGET_DIR/etc/inittab
  echo "psi1:1:wait:/sbin/prodsysinfo /dev/ttyS0" >>$TARGET_DIR/etc/inittab
fi
