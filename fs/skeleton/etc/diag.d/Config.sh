#
# configuration for diagnostic scripts
#

# defaults, if not overridden
iperf_server=192.168.1.2

# these can be set on the boot line or the environment
diag_essid="${diag_essid:-$(kernopt diag_essid)}"
diag_iperf_server="${diag_iperf_server:-$(kernopt diag_iperf_server)}"

#
# general configs here
#

dram_memory=10M		# how much memory to test

wifi_essid="${diag_essid:-factory}"

wired_lan=lan0
wired_wan=wan0

# iperf_server_* can be overriden by environment
iperf_server_lan0="${iperf_server_lan0:-${diag_iperf_server:-$iperf_server}}"
iperf_min_lan0=10		# MBytes/sec

iperf_server_wan0="${iperf_server_wan0:-${diag_iperf_server:-$iperf_server}}"
iperf_min_wan0=10		# MBytes/sec

iperf_server_weth0="${iperf_server_weth0:-${diag_iperf_server:-$iperf_server}}"
iperf_min_weth0=10		# MBytes/sec

iperf_server_weth1="${iperf_server_weth1:-${diag_iperf_server:-$iperf_server}}"
iperf_min_weth1=10		# MBytes/sec

#
# platform specific configs follow
#
PLATFORM_NAME=$(hnvram -qr PLATFORM_NAME)
case "$PLATFORM_NAME" in
  GFHD100)
    ;;
  GFMS100)
    ;;
  GFRG200)
    ;;
  *)
    echo "$0: WARNING: unknown platform '$PLATFORM_NAME', using defaults" 1>&2
    ;;
esac
