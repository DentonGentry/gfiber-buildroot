#!/bin/sh

die() {
  echo "fatal: $*" >&2
  exit 99
}


# Returns true if the string $1 ends with the string $2.
endswith() {
  [ "${1%$2}" != "$1" ]
}


[ -n "$1" ] || die "Usage: $0 <out_dir>"
HOST_DIR="$1/host"
TARGET_DIR="$1/target"
STAGING_DIR="$1/staging"
BUILDROOT_DIR="$(dirname "$0")/../.."

[ -d "$HOST_DIR" ] || die "'$HOST_DIR' is not a directory"
[ -d "$TARGET_DIR" ] || die "'$TARGET_DIR' is not a directory"
[ -d "$STAGING_DIR" ] || die "'$STAGING_DIR' is not a directory"
[ -d "$BUILDROOT_DIR/package" ] ||
    die "'$BUILDROOT_DIR/package' is not a directory"

# Auto-create logging services for all services that don't already have them.
(
  cd "$STAGING_DIR/etc/s6-rc" &&
  echo "considering autologs..." >&2 &&
  rm -rf autologs &&
  mkdir autologs &&
  for d in source/*; do
    if [ ! -e "$d/run" ]; then
      continue
    fi
    if [ -d "$d-log" ]; then
      echo "skipping autologs for '$d': dir '$d-log' exists." >&2
      continue
    fi
    if [ "${d%-log}" != "$d" ]; then
      echo "skipping autologs for '$d': already a log." >&2
      continue
    fi
    pf=
    [ ! -r "$d/producer-for" ] || read pf <"$d/producer-for"
    if [ -n "$pf" -a -d "source/$pf" ]; then
      echo "skipping autologs for '$d': consumer '$pf' exists." >&2
      continue
    fi
    echo "creating autologs for '$d'" >&2
    base="$(basename "$d")" &&
    adir="autologs/$base-log" &&
    mkdir "$adir" &&
    printf "#!/usr/bin/execlineb\nlogos $base" >"$adir/run" &&
    chmod a+x "$adir/run" &&
    echo longrun >"$adir/type" &&
    echo "$base" >"$adir/consumer-for" &&
    echo "$base-log" >"$d/producer-for" ||
        die "failed to create autolog for '$d'"
  done || die "failed to create autologs"
) &&

# Auto-create a bundle containing all available (non-auto) services.
(
  S="$STAGING_DIR/etc/s6-rc" &&
  echo "generating 'all' bundle..." >&2 &&
  rm -rf "$S/auto" &&
  mkdir -p "$S/auto/all" &&
  echo bundle >$S/auto/all/type &&
  for d in $BUILDROOT_DIR/fs/rc/source/* $S/source/*; do
    if [ -e "$d/type" ]; then
      echo "$(basename "$d")"
    fi
  done >"$S/auto/all/contents" ||
      die "failed to create 'all' bundle"
) &&

# Auto-create "virtual" services for all init scripts in /etc/init.d.
(
  for d in $TARGET_DIR/etc/init.d/S*; do
    endswith "$d" "~" && continue
    echo "$(basename "$d")"
  done | (
    cd "$STAGING_DIR/etc/s6-rc" &&
    echo "creating init.d virtual services..." >&2 &&
    while read d; do
      mkdir -p "auto/$d" &&
      echo oneshot >"auto/$d/type" &&
      printf "#!/usr/bin/execlineb\nwait-until-created /tmp/run/$d.init\n" \
          >"auto/$d/up" &&
      chmod a+x "auto/$d/up" || die "failed to create '$d' virtual service"
    done
  ) || die "failed to create virtual services"
) || die "failed to initialize services"

rm -rf "$TARGET_DIR/etc/s6-rc/compiled" &&
mkdir -p "$TARGET_DIR/etc/s6-rc" &&
mkdir -p "$STAGING_DIR/etc/s6-rc/source" &&
"$HOST_DIR/usr/bin/s6-rc-compile" -v2 \
    "$TARGET_DIR/etc/s6-rc/compiled" \
    "$BUILDROOT_DIR/fs/rc/source" \
    "$STAGING_DIR/etc/s6-rc/source" \
    "$STAGING_DIR/etc/s6-rc/autologs" \
    "$STAGING_DIR/etc/s6-rc/auto" ||
  die "failed to compile s6-rc sources"
