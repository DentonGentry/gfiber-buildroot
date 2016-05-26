#!/bin/sh

. /etc/utils.sh

# Utility functions for working with the Chrome browser_shell binaries.

# Provide a more useful 'comm'-like value for our browser_shell. This takes care
# of two problems:
#   1. Distinguishing between the browser, renderer, etc.
#   2. Distinguishing between webapps.
format_chrome_comm()
{
  local pid="$1"
  local args="$2"

  local type_and_rest="${args#*--type=}"
  if [ "$type_and_rest" = "$args" ]; then
    type_and_rest="browser"
  fi

  # Strip any arguments after the shell type off. For the GPU process, reduce
  # the type from 'gpu-process' to just 'gpu'.
  local shell_type="${type_and_rest%%[ -]*}"

  # Now we need the webapp. This is beautifully hacky; only the browser process
  # has an actual URL we can mine the webapp from, however the renderer and gpu
  # processes do have the browser pid as a parameter, so we can read that and
  # work backwards. For the zygote there's nothing we can do but it usually
  # isn't important.
  local web_app
  case "$shell_type" in
    browser)
      web_app=$(get_webapp_for_browser "$args")
      ;;
    renderer|gpu)
      web_app=$(get_webapp_for_channeled_process "$args")
      ;;
    *)
      web_app="unknown"
      ;;
  esac

  echo "${shell_type}_${web_app}"
}

# Given the command-line arguments for the Chromium browser process, extract the
# webapp if possible.
get_webapp_for_browser()
{
  local args="$1"

  if contains "$args" "youtube.com"; then
    echo "youtube"
  elif contains "$args" "oregano"; then
    echo "oregano"
  else
    echo "unknown"
  fi
}

# Given the command-line arguments for a channeled Chromium process (e.g. the
# renderer or gpu), extract the webapp if possible. This does a lookup via the
# browser process.
get_webapp_for_channeled_process()
{
  local args="$1"
  local channel_and_rest="${args#*--channel=}"
  if [ "$channel_and_rest" = "$args" ]; then
    channel_and_rest=""
  fi

  # Strip the non-pid part of the channel and the rest of the args off.
  local browser_pid="${channel_and_rest%%.*}"

  if [ "$browser_pid" != "" ]  && [ "$browser_pid" -ge 0 ]; then
    ps_output=$(ps --no-headers -o cmd "$browser_pid")
    echo $(get_webapp_for_browser "$ps_output")
  else
    echo "unknown"
  fi
}

