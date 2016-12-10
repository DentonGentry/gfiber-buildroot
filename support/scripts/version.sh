#!/bin/sh
# Returns current version being built, without leading platform string
# For ex. "-48-pre1-test-rel-739-gf1d6349"

OUTPUT_DIR="$1"
if [ -n "$OUTPUT_DIR" -a -r "$OUTPUT_DIR/force_version" ]; then
  echo -n "-" && cat "$OUTPUT_DIR/force_version"
  exit
fi

if support/scripts/is-repo.sh; then
  FORALL="repo forall -c"
elif support/scripts/is-git.sh; then
  FORALL="git submodule --quiet foreach"
else
  echo "ERROR: No version control folder found" >&2
  exit 1;
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
  version="-${tagabbrev#*-}-$count-${tagname##*-}"
else
  version="-${tagname#*-}"
fi
echo "$version"
