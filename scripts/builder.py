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
c,chip-revision=   Chip revision [b0]
v,verbose          Increase verbosity
b,bundle-only      Only bundle the image
f,fresh,force      Force rebuild (once=remove stamps, twice=make clean)
x,platform-only    Build less stuff into the app (no webkit, netflix, etc.)
no-init            Don't build the kernel+initramfs
no-app             Don't build the app squashfs
t,test,test-packages Add test packages
d,debug,debug-image  Build debug image with extra debugging features
"""


RED = '\033[1;31m'
GREEN = '\033[1;32m'
YELLOW = '\033[1;33m'
OFF = '\033[0m'


# Possible values for init_or_app
INIT = 'init'  # the kernel + initramfs
APP = 'app'    # the application-layer squashfs


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
      Makedirs(self._Path(INIT, 'images'))
      Makedirs(self._Path(APP, 'images'))
      if not self.opt.bundle_only:
        p_init = None
        p_app = None
        if self.opt.init:
          p_init = multiprocessing.Process(target=self.BuildInitFs)
          p_init.start()
        if self.opt.app:
          p_app = multiprocessing.Process(target=self.BuildAppFs)
          p_app.start()
        if p_init:
          p_init.join()
        if p_app:
          p_app.join()
      self.BundleImage()
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
    print 'DEBUG          :', self.opt.debug
    print 'TEST_IMAGE     :', self.opt.test_packages
    print 'MODEL          :', self.opt.model
    print 'PRODUCT FAMILY :', self.opt.product_family
    print 'VERBOSE        :', self.opt.verbose
    print 'FRESH          :', self.opt.fresh
    print 'BUILDROOT PATH :', self.top_dir
    print 'BUILD PATH     :', self.base_dir
    print '=========================================================='
    sys.stdout.flush()

  def PopenAt(self, cwd, args, **kwargs):
    """Execute Popen in arbitrary dir."""
    p = subprocess.Popen(args, cwd=cwd, **kwargs)
    retval = p.wait()
    if retval:
      raise BuildError('%r returned exit code %r' % (args, retval))

  def _Path(self, init_or_app, *paths):
    return os.path.abspath(os.path.join(self.base_dir, init_or_app, *paths))

  def Make(self, init_or_app, targets):
    """Execute make for buildroot.

    Args:
      init_or_app: either INIT or APP
      targets: which targets to ask make to build ([] means default)
    """
    #TODO(apenwarr): put BCHP_VER elsewhere so 'make' finds it, even if
    #  further builds are not done with this script.
    cmd = ['make', 'O=%s' % self._Path(init_or_app),
           'BCHP_VER=%s' % self.opt.chip_revision.upper()] + targets
    if self.opt.verbose:
      cmd += ['V=1']
    self.PopenAt(self.top_dir, cmd)

  def CleanOutputDir(self, init_or_app):
    d = self._Path(init_or_app)
    Info('Cleaning %r...', d)
    self.Make(init_or_app, ['clean'])

  def BuildConfig(self, init_or_app, filename, **extra):
    """Generate a config file for the given set of options."""
    opts = dict(BR2_PACKAGE_BRUNO_DEBUG=self.opt.debug)
    # TODO(kedong): when the loader can handle more than 40M kernel,
    #   we will add the strip_none back.
    # opts['BR2_STRIP_none'] = 1
    opts.update(extra)

    # We append to the file because the user might have added (unrelated)
    # custom entries, but later lines override earlier ones, so it's
    # safe to just re-append forever.
    localcfg = open(self._Path(init_or_app, '.localconfig'), 'a')
    for key, value in opts.iteritems():
      localcfg.write('%s=%s\n' % (key, value and 'y' or 'n'))
    localcfg.close()

    # Actually generate the config file
    Info('Config file: %r', filename)
    self.Make(init_or_app, [filename + '_rebuild'])

    # Grab all the sources before starting, so we fail faster
    self.Make(init_or_app, ['source'])

  def RemoveStamps(self, init_or_app):
    Info('Cleaning up install stamps...')
    Unlink(self._Path(init_or_app, 'build/.root'))
    UnlinkGlob(self._Path(init_or_app, 'build/*/.stamp*installed'))
    UnlinkGlob(self._Path(init_or_app, 'stamps/*installed'))

  def BuildInitFs(self):
    """Build the kernel + initramfs."""
    if self.opt.fresh >= 2:
      self.CleanOutputDir(INIT)
    self._LogStart('Building kernel + initramfs')
    config_file = ('%s_initramfs_%s%s_defconfig'
                   % (self.opt.product_family,
                      self.opt.model,
                      self.opt.chip_revision))
    Info('kernel + initramfs: config file is %r', config_file)
    self.BuildConfig(INIT, config_file)
    if self.opt.fresh >= 1:
      self.RemoveStamps(INIT)
    self.Make(INIT, [])
    self._LogDone('Building kernel + initramfs')

  def BuildAppFs(self):
    """Build the squashfs (runs after the initramfs and contains the app)."""
    if self.opt.fresh >= 2:
      self.CleanOutputDir(APP)
    self._LogStart('Building app squashfs')
    config_file = ('%s_%s%s_defconfig'
                   % (self.opt.product_family,
                      self.opt.model,
                      self.opt.chip_revision))
    Info('app squashfs: config file is %r', config_file)
    self.BuildConfig(APP, config_file,
                     BR2_PACKAGE_BRUNO_APPS=not self.opt.platform_only,
                     BR2_PACKAGE_BRUNO_TEST=self.opt.test_packages)
    if self.opt.fresh >= 1:
      self.RemoveStamps(APP)
    self.Make(APP, [])
    self._LogDone('Building app squashfs')

  #TODO(apenwarr): postprocessing like this belongs in a buildroot package.
  #  Generating vmlinuz, tarballs, etc are just more build rules like any
  #  other. That way you could cd $OUTDIR and just run 'make' and the right
  #  thing will happen, as long as you've run this script once for setup.
  def BundleImage(self):
    """Create UBI images and installer tarball."""
    self._LogStart('Bundling Image')

    # gzip vmlinux
    if self.opt.init:
      Info('Creating vmlinuz...')
      vmlinux = open(self._Path(INIT, 'images/vmlinux'), 'rb').read()
      vmlinuz = gzip.open(self._Path(INIT, 'images/vmlinuz'), 'wb', 9)
      vmlinuz.write(vmlinux)
      vmlinuz.close()

    # ubinize vmlinuz
    if self.opt.app and self.opt.init:
      Info('Creating ubi image for vmlinuz...')
      ubinize_opts = (open(self._Path(APP, 'staging/etc/kernel_ubi_opts'))
                      .read().strip().split())
      cmd = ([self._Path(INIT, 'host/usr/sbin/ubinize'),
              '-o', self._Path(INIT, 'images/vmlinuz.ubi')]
             + ubinize_opts +
             [self._Path(INIT, 'staging/etc/kernel_ubinize.cfg')])
      self.PopenAt(self._Path(INIT, 'images'), cmd)

    # For user friendliness, show the kernel from the initfs in app/images.
    if self.opt.app and self.opt.init:
      Unlink(self._Path(APP, 'images/vmlinuz'))
      # I might prefer a symlink here, but then 'tar' would do the wrong thing
      os.link(self._Path(INIT, 'images/vmlinuz'),
              self._Path(APP, 'images/vmlinuz'))

    # bundle complete package in tar format
    if self.opt.app:
      tarname = self._Path(APP, 'images/bruno_ginstall_image.tgz')
      Info('Creating %r', tarname)
      tar = tarfile.open(tarname, 'w:gz')
      tar.add(self._Path(APP, 'images/version'), 'version')
      tar.add(self._Path(APP, 'images/vmlinuz'), 'vmlinuz')
      tar.add(self._Path(APP, 'images/rootfs.squashfs_ubi'),
              'rootfs.squashfs_ubi')
      tar.close()

    self._LogDone('Bundling Image')


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
    if opt.debug:
      debug_path = 'debug'
    else:
      debug_path = 'release'
    branch = PopenAndRead(['git', 'rev-parse', '--abbrev-ref', 'HEAD'])
    base_dir = os.path.abspath(os.path.join('../builds', branch, debug_path))
    Warn('Default output dir: %s', base_dir)
  if not opt.platform_only:
    #TODO(apenwarr): put this in the buildroot packages as a "pre-depends"
    #  or something (so it runs early, but only when needed, and doesn't
    #  depend on this script).
    CheckLoasCertificate()
  builder = BuildRootBuilder(base_dir, opt)
  builder.Build()


if __name__ == '__main__':
  main()
