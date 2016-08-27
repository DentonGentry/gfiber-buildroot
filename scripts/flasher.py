#!/usr/bin/python2.7
"""stream update images to gfiber devices."""

import glob
import os
import subprocess
import sys


import options


optspec = """
flasher.py [options...] host1 host2 ... hostN
--
b,basedir=      Read image from under this base directory
f,force         Bypass image version check
i,image=        Use this specific image file
"""

global_serve_map = {}


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

  for host in extra:
    host_ssh = ['ssh', '-o RequestTTY=no', 'root@%s' % host]

    current_version = subprocess.check_output(
        host_ssh + ['cat /etc/version'])
    host_platform, unused_host_build = current_version.split('-', 1)

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

    install_cmd = ('ginstall -t - && '
                   'echo "Installed image successfully; rebooting" && '
                   '( sleep 1; reboot; ) &')

    image_file = open(global_serve_map[image])
    subprocess.check_call(host_ssh + [install_cmd], stdin=image_file)


if __name__ == '__main__':
  main()
