#!/usr/bin/python
"""Dynamic DNS for developer CPE devices.

Sends IP and serial number to the gfcpe-ddns server. This server
stores these pairs and allows developers to address their devices
with 'serial-number.d.gfcpe.com'
See g3doc for more info
"""

import commands
import httplib
import json
import os
import socket
import subprocess
import time

GOOGLE_PUBLIC_DNS = "8.8.8.8"
ONU_STAT_FILE = "/tmp/cwmp/monitoring/onu/onustats.json"

SERVER_ADDR = "gfcpe-ddns-server.gfcpe.com"
PORT_NUMBER = 4444

RESTART_TIME = 60


def get_my_serial():
  return commands.getstatusoutput(("serial"))[1]


def get_onu_serial():
  return commands.getstatusoutput(
      "cat " + ONU_STAT_FILE + " | " +
      "grep serial | " +
      "cut -d '\"' -f4")[1]


def get_my_ip(addr_family):
  s = socket.socket(addr_family, socket.SOCK_DGRAM)
  s.connect((GOOGLE_PUBLIC_DNS, 80))
  ip = s.getsockname()[0]
  s.close()
  return ip


def get_onu_ip():
  return commands.getstatusoutput(
      "cat " + ONU_STAT_FILE + " | " +
      "grep ipv6 | " +
      "cut -d '\"' -f4")[1]


def send_ip(serial_no, ipv4, ipv6):
  content = {"serialNo": serial_no, "ipv4": ipv4, "ipv6": ipv6}

  connection = httplib.HTTPConnection(SERVER_ADDR, PORT_NUMBER)
  headers = {"Content-type": "application/json"}
  connection.request("POST", "/", json.dumps(content), headers)


def main():
  while True:
    ipv4 = ""
    # Network boxes also have public ipv4 address
    if subprocess.call(("is-network-box")) == 0:
      ipv4 = get_my_ip(socket.AF_INET)

    send_ip(get_my_serial(), ipv4, get_my_ip(socket.AF_INET6))

    # Send fiber jack's IP on its behalf
    if os.path.isfile(ONU_STAT_FILE):
      send_ip(get_onu_serial(), "", get_onu_ip())

    time.sleep(RESTART_TIME)

if __name__ == "__main__":
  main()
