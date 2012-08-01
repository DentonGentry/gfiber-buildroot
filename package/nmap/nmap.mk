NMAP_VERSION=6.01
NMAP_SITE=http://nmap.org/dist
NMAP_SOURCE=nmap-$(NMAP_VERSION).tgz
NMAP_DEPENDENCIES=openssl libpcap pcre lua

$(eval $(call AUTOTARGETS))
