#!/usr/bin/env python
# Copyright 2012 Google Inc. All Rights Reserved.

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
import os
import subprocess
import sys
import time
import options

__author__ = 'kedong@google.com (Ke Dong)'


optspec = """
builder.py [options...] [output-directory]
--
C,config=          buildroot config file [gftv100_defconfig]
v,verbose          Increase verbosity
f,fresh,force      Force rebuild (once=remove stamps, twice=make clean)
x,platform-only    Build less stuff into the app (no webkit, netflix, etc.)
r,production       Use production signing keys and license
j,jobs=            Number of parallel jobs for make to use (make -j) [12]
k,key-suffix=      Suffix for signing keys
openbox            Use openbox bootloader (forces --no-production)
no-build           Don't build, just configure
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
    print 'CONFIG         :', self.opt.config
    print 'VERBOSE        :', self.opt.verbose
    print 'FRESH          :', self.opt.fresh
    print 'PRODUCTION     :', self.opt.production
    print 'OPENBOX        :', self.opt.openbox
    print 'BUILDROOT PATH :', self.top_dir
    print 'BUILD PATH     :', self.base_dir
    print 'KEY SUFFIX     :', self.opt.key_suffix
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
      parallel: true if you want make to run a parallel build.
    """
    cmd = ['make', 'O=%s' % self._Path()] + targets
    if self.opt.verbose:
      cmd += ['V=1']
    if parallel:
      cmd += ['-j%d' % self.opt.jobs, '-l%d' % self.opt.jobs]
    self.PopenAt(self.top_dir, cmd)

  def CleanOutputDir(self):
    d = self._Path()
    Info('Cleaning %r...', d)
    self.Make(['clean'], parallel=True)

  def BuildConfig(self, filename, **extra):
    """Generate a config file for the given set of options."""
    opts = dict(BR2_PACKAGE_GOOGLE_PROD=self.opt.production,
                BR2_PACKAGE_GOOGLE_OPENBOX=self.opt.openbox)
    # Disable ccache for production builds.
    if self.opt.production:
      opts['BR2_CCACHE'] = 0
    opts.update(extra)

    # We append to the file because the user might have added (unrelated)
    # custom entries, but later lines override earlier ones, so it's
    # safe to just re-append forever.
    localcfg = open(self._Path('.localconfig'), 'a')
    for key, value in opts.iteritems():
      localcfg.write('%s=%s\n' % (key, value and 'y' or 'n'))
    if self.opt.key_suffix:
      localcfg.write('BR2_PACKAGE_GOOGLE_KEY_SUFFIX="%s"\n' %
                     self.opt.key_suffix)
    localcfg.close()

    # Actually generate the config file
    Info('Config file: %r', filename)
    self.Make([filename + '_rebuild'], parallel=False)

  def RemoveStamps(self):
    Info('Cleaning up install stamps...')
    self.Make(['remove-stamps'], parallel=True)

  def BuildAppFs(self):
    """Build the kernel + simpleramfs + squashfs."""
    if self.opt.fresh >= 2:
      self.CleanOutputDir()
    self._LogStart('Building app')
    Info('app: config file is %r', self.opt.config)
    if self.opt.platform_only:
      self.BuildConfig(self.opt.config,
                       BR2_PACKAGE_GOOGLE_PLATFORM_ONLY=True)
    else:
      self.BuildConfig(self.opt.config)
    if self.opt.fresh >= 1:
      self.RemoveStamps()
    if self.opt.build:
      self.Make([], parallel=True)
    else:
      self.Make(['worldsetup'], parallel=True)
    self._LogDone('Building app')


def main():
  os.chdir(os.path.dirname(sys.argv[0]) + '/..')
  o = options.Options(optspec)
  (opt, _, extra) = o.parse(sys.argv[1:])
  if '/' in opt.config:
    o.fatal('--config must be a filename in %s/configs' % os.getcwd())
  if not os.path.exists(os.path.join('configs', opt.config)):
    o.fatal('--config %r does not exist' % opt.config)
  if not opt.platform_only and not os.path.exists('../vendor/sagetv'):
    o.fatal('../vendor/sagetv not available; you probably need to use -x')
  if extra:
    if len(extra) > 1:
      o.fatal('at most one output directory expected')
    base_dir = os.path.abspath(extra[0])
  else:
    base_dir = os.path.abspath('../out')
    Warn('Default output dir: %s', base_dir)
  if not base_dir or base_dir[-1] in ('-', '.', ',') or '$' in base_dir:
    o.fatal('weird output dir %r; check your scripts.' % base_dir)
  builder = BuildRootBuilder(base_dir, opt)
  builder.Build()


if __name__ == '__main__':
  main()
