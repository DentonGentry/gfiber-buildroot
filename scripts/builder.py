#!/usr/bin/env python
# Copyright 2011 Google Inc. All Rights Reserved.

"""Script for building Bruno images."""

import gzip
import os
import shutil
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
n,no-initramfs     Build kernel without initramfs
d,debug,debug-image  Build debug image with extra debugging features
b,bundle-only      Only bundle the image
f,fresh            Build a fresh image (ie. build all from scratch)
x,platform-only    Build only base platform (no webkit, netflix, etc.)
t,test,test-packages Add test packages
"""


RED = '\033[1;31m'
GREEN = '\033[1;32m'
YELLOW = '\033[1;33m'
OFF = '\033[0m'


def _Log(color, fmt, args):
  if args:
    print color + (fmt % args) + OFF
  else:
    print color + str(fmt) + OFF


def Info(fmt, *args):
  _Log(GREEN, fmt, args)


def Warn(fmt, *args):
  _Log(YELLOW, fmt, args)


def Error(fmt, *args):
  _Log(RED, fmt, args)


class BuildError(Exception):
  pass


class BuildRootBuilder(object):
  """Builder class to wrap up buildroot."""

  def __init__(self, opt):
    self.opt = opt

  def Build(self):
    """Run the build."""
    starttime = time.time()
    try:
      self.PrintOptions()
      if self.opt.fresh:
        self.CleanBuildOutputDir()
      if not self.opt.bundle_only:
        self.BuildInitramfs()
        self.BuildRootfs()
      self.BundleImage()
    except BuildError as e:
      #TODO(apenwarr): should return nonzero exit code back to shell
      Error(e)
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
    print 'INITRAMFS      :', self.opt.initramfs
    print 'MODEL          :', self.opt.model
    print 'PRODUCT FAMILY :', self.opt.product_family
    print 'VERBOSE        :', self.opt.verbose
    print 'FRESH          :', self.opt.fresh
    print 'BUILDROOT PATH :', self.opt.top_dir
    print 'BUILD PATH     :', self.opt.base_dir
    print '=========================================================='

  def PopenDir(self, cwd, args, **kwargs):
    """Execute Popen in arbitrary dir."""
    p = subprocess.Popen(args, cwd=cwd, **kwargs)
    if p.wait():
      raise BuildError('Failed to execute %r' % args)

  def Make(self, make_options):
    """Execute make for buildroot.

    Args:
      make_options: list of strings to pass to make
    """
    cmd = ['make', 'O=%s' % self.opt.base_dir] + make_options
    self.PopenDir(self.opt.top_dir, cmd)

  def CleanBuildOutputDir(self):
    Info('Cleaning %r...', self.opt.base_dir)
    self.Make(['clean'])
    if os.path.exists(os.path.join(self.opt.base_dir, '.localconfig')):
      os.unlink(os.path.join(self.opt.base_dir, '.localconfig'))

  def BuildConfig(self, config_file):
    """Generate a config file for the current set of options."""
    if self.opt.debug:
      localcfg = file(os.path.join(self.opt.base_dir, '.localconfig'), 'a')
      # TODO(kedong): when the loader can handle more than 40M kernel,
      # we will add the strip_none back.
      # localcfg.write('BR2_STRIP_none=y\n')
      localcfg.write('BR2_PACKAGE_BRUNO_DEBUG=y\n')
      localcfg.close()
    Info('Final config file: %r...', config_file)
    self.Make([config_file + '_rebuild'])
    # Grab all the sources we need for this config
    self.Make(['source'])

  def ForceCleanPackages(self):
    self._LogStart('Force cleaning packages')
    packages = ['bruno', 'util-linux']
    if os.path.exists(os.path.join(self.opt.top_dir, '.forceclean')):
      packages.extend(file(os.path.join(self.opt.top_dir, '.forceclean'))
                      .readlines())
    packages = [p.strip() for p in packages]
    Warn('Cleaning packages: %s', ' '.join(packages))
    self.Make(['%s-dirclean' % p for p in packages])
    self._LogDone('Completed cleaning packages')

  def BuildInitramfs(self):
    """Build the initramfs (that gets linked into the kernel)."""
    if not self.opt.initramfs:
      return
    self._LogStart('Building Initramfs')
    config_file = ('%s_initramfs_%s%s_defconfig'
                   % (self.opt.product_family,
                      self.opt.model,
                      self.opt.chip_revision))
    Info('Use config file %r for initramfs.', config_file)
    self.BuildConfig(config_file)
    # clean up target
    build_dir = os.path.join(self.opt.base_dir, 'build')
    target_dir = os.path.join(self.opt.base_dir, 'target')
    stamp_dir = os.path.join(self.opt.base_dir, 'stamps')
    self.ForceCleanPackages()
    if os.path.exists(target_dir):
      Info('Removing target directory...')
      shutil.rmtree(target_dir)
    if os.path.exists(build_dir):
      Info('Cleaning up install stamps...')
      rootfile = os.path.join(build_dir, '.root')
      if os.path.exists(rootfile):
        os.remove(rootfile)
      cmd = 'find ' + build_dir + ' -name .stamp*installed -exec rm {} \;'
      self.PopenDir(self.opt.top_dir, cmd, shell=True)
      if os.path.exists(stamp_dir):
        cmd = 'find ' + stamp_dir + ' -name *installed -exec rm {} \;'
        self.PopenDir(self.opt.top_dir, cmd, shell=True)
    args = []
    args.append('BCHP_VER='+self.opt.chip_revision.upper())
    if self.opt.verbose:
      args.append('V=1')
    self.Make(args)
    vmlinux = os.path.join(self.opt.base_dir, 'images/vmlinux')
    # save vmlinux to vmlinux-initramfs to prevent overwrite
    shutil.copyfile(vmlinux, vmlinux + '-initramfs')
    self._LogDone('Building Initramfs')

  def BuildRootfs(self):
    """Build the root filesystem (ie. the squashfs, not the initramfs)."""
    self._LogStart('Building Rootfs')
    config_file = ('%s_%s%s_defconfig'
                   % (self.opt.product_family,
                      self.opt.model,
                      self.opt.chip_revision))
    # Add packages if not platform build:
    Info('Use config file %r for rootfs.', config_file)
    localcfg = file(os.path.join(self.opt.base_dir, '.localconfig'), 'a')
    if self.opt.platform_only:
      Info('Building platform-only image.')
      localcfg.write('BR2_PACKAGE_BRUNO_APPS=n\n')
    else:
      Info('Building full image.')
      localcfg.write('BR2_PACKAGE_BRUNO_APPS=y\n')
    if self.opt.test_packages:
      Info('Adding test packages')
      localcfg.write('BR2_PACKAGE_BRUNO_TEST=y\n')
    localcfg.close()
    self.BuildConfig(config_file)
    args = []
    args.append('BCHP_VER='+self.opt.chip_revision.upper())
    if self.opt.verbose:
      args.append('V=1')
    self.ForceCleanPackages()
    self.Make(args)
    self._LogDone('Building Rootfs')

  def BundleImage(self):
    """Create UBI images and installer tarball."""
    self._LogStart('Bundling Image')
    if self.opt.product_family == 'bruno':
      binaries_dir = os.path.abspath(self.opt.base_dir + '/images')
      staging_dir = os.path.abspath(self.opt.base_dir + '/staging')
      host_dir = os.path.abspath(self.opt.base_dir + '/host')
      opt_file = open(staging_dir + '/etc/kernel_ubi_opts')
      ubi_ubinize_opts = ' '.join(opt_file.read().strip().split())
      opt_file.close()
      # gzip vmlinux
      Info('Creating vmlinuz...')
      vmlinux_path = binaries_dir + '/vmlinux'
      if self.opt.initramfs:
        vmlinux_path += '-initramfs'
      if not os.path.exists(vmlinux_path):
        raise BuildError('Cannot find %r' % vmlinux_path)
      vmlinux = open(vmlinux_path, 'rb')
      vmlinuz = gzip.open(binaries_dir + '/vmlinuz', 'wb', 9)
      vmlinuz.write(vmlinux.read())
      vmlinuz.close()
      vmlinux.close()
      # ubinize vmlinuz
      Info('Creating ubi image for vmlinuz...')
      cmd = ('%s/usr/sbin/ubinize -o %s/vmlinuz.ubi %s '
             '%s/etc/kernel_ubinize.cfg'
             % (host_dir, binaries_dir, ubi_ubinize_opts, staging_dir))
      self.PopenDir(binaries_dir, cmd, shell=True)
      # bundle image in tar format
      Info('Creating final tgz image...')
      tar = tarfile.open(binaries_dir + '/bruno_ginstall_image.tgz', 'w:gz')
      tar.add(binaries_dir + '/vmlinuz', 'vmlinuz')
      tar.add(binaries_dir + '/rootfs.squashfs_ubi', 'rootfs.squashfs_ubi')
      tar.add(binaries_dir + '/version', 'version')
      tar.close()
    self._LogDone('Bundling Image')


def main():
  o = options.Options(optspec)
  (opt, _, extra) = o.parse(sys.argv[1:])
  if extra:
    if len(extra) > 1:
      o.fatal('at most one output-directory expected')
    opt.base_dir = os.path.abspath(extra[0])
  else:
    if opt.debug:
      debug_path = 'debug'
    else:
      debug_path = 'release'
    gitpwd = subprocess.Popen('git rev-parse --abbrev-ref HEAD'.split(),
                              stdout=subprocess.PIPE).communicate()[0].strip()
    opt.base_dir = os.path.abspath(os.path.join('..', 'builds',
                                                gitpwd, debug_path))
    Warn('Using default build directory of buildroot branch: %s',
         opt.base_dir)
  if not os.path.exists(opt.base_dir):
    Warn('Build directory %r does not exist; creating...', opt.base_dir)
    os.makedirs(opt.base_dir)
  opt.top_dir = os.path.abspath(os.path.dirname(sys.argv[0]) + '/..')
  builder = BuildRootBuilder(opt)
  builder.Build()


if __name__ == '__main__':
  main()
