#!/usr/bin/env python
# Copyright 2011 Google Inc. All Rights Reserved.

"""Script for building Bruno images.

NOTE NOTE NOTE NOTE NOTE!

Please consider carefully whether you really want to add stuff to this script.
Almost everything you might want in this script should be added as a
buildroot package instead.  Otherwise people who want to do a quick rebuild
of a particular package using 'make' won't be able to do so.

This script already does too much stuff.  Most of its existing features
should be migrated out into packages eventually.  You almost certainly don't
want to add more.

Think of the goal for this script as running ./configure in an autoconf
program.  Everybody needs to do it to set their options, but not every
time you run an incremental build.
"""

import errno
import glob
import gzip
import multiprocessing
import os
import re
import subprocess
import sys
import tarfile
import time
import options

__author__ = 'kedong@google.com (Ke Dong)'


optspec = """
builder.py [options...] [output-directory]
--
p,product-family=  Product family (eg. bruno, bcm7425) [bruno]
m,model=           Model name [gfhd100]
c,chip-revision=   Chip revision [b2]
v,verbose          Increase verbosity
b,bundle-only      Only bundle the image
f,fresh,force      Force rebuild (once=remove stamps, twice=make clean)
x,platform-only    Build less stuff into the app (no webkit, netflix, etc.)
r,production       Use production signing keys and license
"""


RED = '\033[1;31m'
GREEN = '\033[1;32m'
YELLOW = '\033[1;33m'
OFF = '\033[0m'


def _Log(color, fmt, args):
  sys.stderr.flush()
  if args:
    print color + (fmt % args) + OFF
  else:
    print color + str(fmt) + OFF
  sys.stdout.flush()


def Info(fmt, *args):
  _Log(GREEN, fmt, args)


def Warn(fmt, *args):
  _Log(YELLOW, fmt, args)


def Error(fmt, *args):
  _Log(RED, fmt, args)


class SubprocError(Exception):
  pass


def PopenAndRead(args, **kwargs):
  nkwargs = dict(stdout=subprocess.PIPE)
  nkwargs.update(kwargs)
  p = subprocess.Popen(args, **nkwargs)
  data = p.stdout.read()
  retval = p.wait()
  if retval:
    raise SubprocError('%r returned exit code %d' % (args, retval))
  return data.strip()


class BuildError(Exception):
  pass


def Makedirs(dirname):
  try:
    os.makedirs(dirname)
  except OSError, e:
    if e.errno == errno.EEXIST:
      pass
    else:
      raise


def Unlink(filename):
  try:
    os.unlink(filename)
  except OSError, e:
    if e.errno == errno.ENOENT:
      pass
    else:
      raise


def UnlinkGlob(g):
  for filename in glob.glob(g):
    Unlink(filename)


class BuildRootBuilder(object):
  """Builder class to wrap up buildroot."""

  def __init__(self, base_dir, opt):
    self.top_dir = os.path.abspath('.')
    self.base_dir = base_dir
    self.opt = opt

  def Build(self):
    """Run the build."""
    starttime = time.time()
    try:
      self.PrintOptions()
      Makedirs(self._Path('images'))
      self.BuildAppFs()
    finally:
      endtime = time.time()
      elapsed = endtime - starttime
      Info('Time executed: %d:%02d', elapsed / 60, elapsed % 60)

  def _LogStart(self, info):
    Info('##### Start %s', info)

  def _LogDone(self, info):
    Info('##### Done %s', info)

  def PrintOptions(self):
    """Print the currently-selected options."""
    print '=========================================================='
    print 'CHIP REVISION  :', self.opt.chip_revision
    print 'MODEL          :', self.opt.model
    print 'PRODUCT FAMILY :', self.opt.product_family
    print 'VERBOSE        :', self.opt.verbose
    print 'FRESH          :', self.opt.fresh
    print 'PRODUCTION     :', self.opt.production
    print 'BUILDROOT PATH :', self.top_dir
    print 'BUILD PATH     :', self.base_dir
    print '=========================================================='
    sys.stdout.flush()

  def PopenAt(self, cwd, args, **kwargs):
    """Execute Popen in arbitrary dir."""
    try:
      p = subprocess.Popen(args, cwd=cwd, **kwargs)
    except OSError, e:
      raise BuildError('%r: %s' % (args, e))
    retval = p.wait()
    if retval:
      raise BuildError('%r returned exit code %r' % (args, retval))

  def _Path(self, *paths):
    return os.path.abspath(os.path.join(self.base_dir, *paths))

  def Make(self, targets, parallel):
    """Execute make for buildroot.

    Args:
      targets: which targets to ask make to build ([] means default)
    """
    cmd = ['make', 'O=%s' % self._Path()] + targets
    if self.opt.verbose:
      cmd += ['V=1']
    if parallel:
      cmd += ['-j', '-l12']
    self.PopenAt(self.top_dir, cmd)

  def CleanOutputDir(self):
    d = self._Path()
    Info('Cleaning %r...', d)
    self.Make(['clean'], parallel=True)

  def BuildConfig(self, filename, **extra):
    """Generate a config file for the given set of options."""
    opts = dict(BR2_PACKAGE_BRUNO_PROD=self.opt.production)
    opts.update(extra)

    # We append to the file because the user might have added (unrelated)
    # custom entries, but later lines override earlier ones, so it's
    # safe to just re-append forever.
    localcfg = open(self._Path('.localconfig'), 'a')
    for key, value in opts.iteritems():
      localcfg.write('%s=%s\n' % (key, value and 'y' or 'n'))
    localcfg.close()

    # Actually generate the config file
    Info('Config file: %r', filename)
    self.Make([filename + '_rebuild'], parallel=False)

    # Grab all the sources before starting, so we fail faster
    self.Make(['source'], parallel=True)

  def RemoveStamps(self):
    Info('Cleaning up install stamps...')
    self.Make(['remove-stamps'], parallel=True)

  def BuildAppFs(self):
    """Build the kernel + simpleramfs + squashfs."""
    if self.opt.fresh >= 2:
      self.CleanOutputDir()
    self._LogStart('Building app')
    config_file = ('%s_%s%s_defconfig'
                   % (self.opt.product_family,
                      self.opt.model,
                      self.opt.chip_revision))
    Info('app: config file is %r', config_file)
    self.BuildConfig(config_file,
                     BR2_PACKAGE_BRUNO_APPS=not self.opt.platform_only)
    if self.opt.fresh >= 1:
      self.RemoveStamps()
    self.Make([], parallel=True)
    if self.opt.production:
      # shred keys and signing related information.
      self.Make(['bcm_signing-uninstall'])
    self._LogDone('Building app')


def LoasTimeLeft():
  try:
    loasstat = PopenAndRead(['prodcertstatus', '--check_loas'])
  except SubprocError:
    pass
  else:
    g = re.match(r'LOAS cert expires in (\d+):(\d+)', loasstat)
    if g:
      return int(g.group(1))
  # otherwise returns None: no valid certificate


def CheckLoasCertificate():
  loas_time_left = LoasTimeLeft()
  if not loas_time_left:
    Error('Your LOAS certificate has expired.\n'
          'Please use prodaccess to renew your LOAS certificate.\n')
    sys.exit(1)
  elif loas_time_left < 2:
    Error('Your LOAS certificate is only good for less than 2 hours.\n'
          'Please use prodaccess to renew your LOAS certificate.\n')
    sys.exit(1)


def main():
  os.chdir(os.path.dirname(sys.argv[0]) + '/..')
  o = options.Options(optspec)
  (opt, _, extra) = o.parse(sys.argv[1:])
  if extra:
    if len(extra) > 1:
      o.fatal('at most one output directory expected')
    base_dir = os.path.abspath(extra[0])
  else:
    base_dir = os.path.abspath('../out')
    Warn('Default output dir: %s', base_dir)
  #TODO(apenwarr): put LOAS check in the buildroot packages as a "pre-depends"
  #  or something (so it runs early, but only when needed, and doesn't
  #  depend on this script).
  CheckLoasCertificate()
  builder = BuildRootBuilder(base_dir, opt)
  builder.Build()


if __name__ == '__main__':
  main()
