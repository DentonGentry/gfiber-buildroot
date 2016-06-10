#!/bin/sh

case "$1" in
    start|"")
	if [ ! -d /tmp/avahi-autoipd ]; then
	    rm -rf /tmp/avahi-autoipd
	    mkdir /tmp/avahi-autoipd
	    chown default.default /tmp/avahi-autoipd
	fi
	;;
    stop) ;;
    restart|reload)
	$0 stop; $0 start
	;;
    *)
	echo "Usage: S05avahi-setup.sh {start|stop}" >&2
	exit 1
	;;
esac
