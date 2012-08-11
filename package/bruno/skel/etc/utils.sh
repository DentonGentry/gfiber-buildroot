#!/bin/bash

# Useful shell utility functions.

atomic() {
  local filename="$1" newval="$2"
  shift

  # Only rewrite the file if it's different from before.  This helps avoid
  # unnecessary flash churn.
  if [ ! -e $filename ] || [ "$(cat $filename)" != "$newval" ]; then
    rm -f $filename.new
    echo "$@" >$filename.new
    mv $filename.new $filename
  fi
}
