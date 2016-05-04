#!/usr/bin/python2.7
"""stream update images to gfiber devices."""

import BaseHTTPServer
import glob
import os
import re
import shutil
import SocketServer
import subprocess
import sys
import threading
import urlparse


import options


optspec = """
flasher.py [options...] host1 host2 ... hostN
--
b,basedir=      Read image from under this base directory
f,force         Bypass image version check
i,image=        Use this specific image file
"""

global_serve_map = {}


class ImageHTTPRequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):
  """Handle HTTP requests for images."""

  # pylint:disable=invalid-name
  def do_GET(self):
    """Handle GET requests."""
    f = self.SendHead()
    if f:
      shutil.copyfileobj(f, self.wfile)
      f.close()

  # pylint:disable=invalid-name
  def do_HEAD(self):
    """Handle HEAD requests. Required by Handler interface, may not be used."""
    f = self.SendHead()
    if f:
      f.close()

  def SendHead(self):
    """Send headers and return fd to requested file."""
    path = urlparse.urlparse(self.path)[2]
    head, tail = os.path.split(path)
    if head != '/':
      self.send_error(404, 'File not found')
      return None
    elif tail not in global_serve_map:
      self.send_error(404, 'File not found')
      return None
    else:
      try:
        f = open(global_serve_map[tail], 'rb')
      except IOError:
        self.send_error(404, 'File not found')
        return None

    self.send_response(200)
    self.send_header('Content-type', 'application/octet-stream')
    fs = os.fstat(f.fileno())
    self.send_header('Content-length', str(fs.st_size))
    self.end_headers()
    return f


def ServeImages():
  handler = ImageHTTPRequestHandler
  httpd = SocketServer.TCPServer(('', 0), handler)
  httpd_thread = threading.Thread(target=httpd.serve_forever)
  httpd_thread.start()
  return httpd


def GetServerIP(remote_ip):
  unused_iface = ''
  iface_addr = ''
  for line in subprocess.check_output(['ip', 'addr']).splitlines():
    iface_match = re.match(r'\d+: ([a-z0-9]+):', line)
    if iface_match:
      unused_iface = iface_match.group(1)
      iface_addr = ''
      continue

    addr_match = re.match(r'\s+inet6? (.*?)/\d+ ', line)
    if addr_match:
      addr = addr_match.group(1)
      if not iface_addr:
        iface_addr = addr

      if addr == remote_ip:
        return iface_addr


def FindImages(basedir):
  """Find our Buildroot directory, then return paths to all its images."""
  if not basedir:
    basedir = os.getcwd()

  search_dir = basedir
  last_search_dir = ''
  while last_search_dir != '/':
    dirents = os.listdir(search_dir)
    if 'buildroot' in dirents:
      break
    last_search_dir = search_dir
    search_dir, _ = os.path.split(basedir)
  else:
    raise OSError('buildroot directory not found in %r or its parents' %
                  basedir)

  images_glob = os.path.join(os.path.realpath(search_dir), '*/images/*.gi')
  images = glob.glob(images_glob)

  serve_map = {}
  latest_map = {}

  for image in images:
    tail = os.path.basename(image)
    if tail == 'latest.gi':
      tail = os.path.basename(os.path.realpath(image))
      platform, _ = tail.split('-', 1)
      latest_map[platform] = tail

    serve_map[tail] = image

  return serve_map, latest_map


def main():
  global global_serve_map
  os.chdir(os.path.join(os.path.dirname(sys.argv[0]), '..'))
  o = options.Options(optspec)
  (opt, _, extra) = o.parse(sys.argv[1:])

  if not extra:
    o.fatal('must supply at least one host to flash')

  global_serve_map, latest_map = FindImages(opt.basedir)
  try:
    httpd = ServeImages()

    for host in extra:
      host_ssh = ['ssh', '-o RequestTTY=no', 'root@%s' % host]
      # Note: these are 'remote' and 'local' from the perspective of the
      # destination server, not us, so we are 'remote' here.
      host_parms = subprocess.check_output(
          # the leading space in echo's arg is required since /etc/version may
          # lack a trailing newline, depending on the build.
          host_ssh + ['cat /etc/version; echo " $SSH_CONNECTION"'])

      # discard remote_port, local_ip, local_port from $SSH_CONNECTION
      current_version, remote_ip = host_parms.split()[:2]
      host_platform, unused_host_build = current_version.split('-', 1)
      server_ip = GetServerIP(remote_ip)

      if opt.image:
        image_file = os.path.basename(opt.image)
        requested_version = os.path.splitext(image_file)[0]
        unused_platform, build = requested_version.split('-', 1)

        image = '%s-%s.gi' % (host_platform, build)
        if image not in global_serve_map:
          global_serve_map[image] = opt.image
      else:
        image = latest_map[host_platform]

      if image == '%s.gi' % current_version and not opt.force:
        print >> sys.stderr, ('Skipping host %s, already running version %s' %
                              (host, current_version))
        print >> sys.stderr, 'Run again with --force to override this.'
        continue

      image_url = 'http://%s:%d/%s' % (server_ip, httpd.server_address[1],
                                       image)
      install_cmd = ('ginstall -t %s && ' % image_url +
                     'echo "Installed image successfully; rebooting" && '
                     '( sleep 1; reboot; ) &')

      subprocess.check_call(host_ssh + [install_cmd])
  finally:
    httpd.shutdown()


if __name__ == '__main__':
  main()
