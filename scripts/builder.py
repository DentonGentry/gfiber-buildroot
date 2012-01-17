#!/usr/bin/env python
# Copyright 2011 Google Inc. All Rights Reserved.

"""Builder for customizing bruno image build.

A detailed description of builder.
"""

import gzip
import os
import sys
import subprocess
import tarfile
import shutil
from optparse import OptionParser

__author__    = "kedong@google.com (Ke Dong)"
__copyright__ = "Copyright 2011, Google Inc."

class Logger():
  RED = '\033[1;31m'
  GREEN = '\033[1;32m'
  YELLOW = '\033[1;33m'
  OFF = '\033[0m'

  @staticmethod
  def info(info):
    print Logger.GREEN + info + Logger.OFF

  @staticmethod
  def warn(warn):
    print Logger.YELLOW + warn + Logger.OFF

  @staticmethod
  def error(error):
    print Logger.RED + error + Logger.OFF

class BuildError(Exception):
  """BuildError class for tracing build error"""
  def __init__(self, value):
    self.value = value
  def __str__(self):
    return repr(self.value)

class BuildRootBuilder:
  """Builder class to wrap up buildroot"""
  def __init__(self, options):
    self.options = options

  def build(self):
    try:
      self.print_options()
      if not self.options.bundle_only:
        self.build_initramfs()
        self.build_rootfs()
      self.bundle_image()
    except BuildError as e:
      Logger.error(str(e))
      raise
    return

  @staticmethod
  def __log_start(info):
    Logger.info("##### Start " + info)

  @staticmethod
  def __log_done(info):
    Logger.info("##### Done " + info)

  def print_options(self):
    print "=========================================================="
    print "CHIP REVISION  :", self.options.chip_revision
    print "DEBUG          :", self.options.debug
    print "INITRAMFS      :", self.options.initramfs
    print "MODEL          :", self.options.model
    print "PRODUCT FAMILY :", self.options.product_family
    print "VERBOSE        :", self.options.verbose
    print "BUILDROOT PATH :", self.options.top_dir
    print "BUILD PATH     :", self.options.base_dir
    print "=========================================================="

  def build_config(self, config_file):
    if self.options.debug:
      config_file += "_debug"
    Logger.info("Final config file: " + config_file + "...");
    cmd = ["make", "O="+self.options.base_dir, config_file]
    p = subprocess.Popen(cmd, cwd=self.options.top_dir)
    p.communicate()
    if p.returncode != 0:
      raise BuildError("Failed to execute [" + ' '.join(cmd) +"]")
    return

  def build_initramfs(self):
    if not self.options.initramfs:
      return
    BuildRootBuilder.__log_start("Building Initramfs")
    config_file = self.options.product_family + "_initramfs_" + \
        self.options.model + self.options.chip_revision + "_defconfig"
    Logger.info("Use config file " + config_file + " for initramfs.")
    self.build_config(config_file)
    # clean up target
    build_dir = self.options.base_dir + "/build"
    target_dir = self.options.base_dir + "/target"
    stamp_dir = self.options.base_dir + "/stamps"
    if os.path.exists(target_dir):
      Logger.info("Removing target directory...");
      shutil.rmtree(target_dir)
    if os.path.exists(build_dir):
      Logger.info("Cleaning up install stamps...");
      if os.path.exists(build_dir + "/.root"):
        os.remove(build_dir + "/.root")
      cmd = "find " + build_dir + " -name .stamp*installed -exec rm {} \;"
      p = subprocess.Popen(cmd, cwd=self.options.top_dir, shell=True)
      p.communicate()
      if p.returncode != 0:
        raise BuildError("Failed to execute [" + cmd + "]")
      if os.path.exists(stamp_dir):
        cmd = "find " + stamp_dir + " -name *installed -exec rm {} \;"
        p = subprocess.Popen(cmd, cwd=self.options.top_dir, shell=True)
        p.communicate()
        if p.returncode != 0:
         raise BuildError("Failed to execute [" + cmd + "]")
    cmd = ["make"]
    if (self.options.verbose):
      cmd.append("V=1")
    cmd.append("O=" + self.options.base_dir)
    p = subprocess.Popen(cmd, cwd=self.options.top_dir)
    p.communicate()
    if p.returncode != 0:
      raise BuildError("Failed to execute [" + ' '.join(cmd) +"]")
    vmlinux=self.options.base_dir+"/images/vmlinux"
    # save vmlinux to vmlinux-initramfs to prevent overwrite
    shutil.copyfile(vmlinux, vmlinux+"-initramfs")
    BuildRootBuilder.__log_done("Building Initramfs")
    return

  def build_rootfs(self):
    BuildRootBuilder.__log_start("Building Rootfs")
    config_file = self.options.product_family + '_' + self.options.model + \
        self.options.chip_revision + "_defconfig"
    Logger.info("Use config file " + config_file + " for rootfs.")
    self.build_config(config_file)
    cmd = ["make"]
    if (self.options.verbose):
      cmd.append("V=1")
    cmd.append("O=" + self.options.base_dir)
    p = subprocess.Popen(cmd, cwd=self.options.top_dir)
    p.communicate()
    if p.returncode != 0:
      raise BuildError("Failed to execute [" + ' '.join(cmd) +"]")
    BuildRootBuilder.__log_done("Building Rootfs")
    return

  def bundle_image(self):
    BuildRootBuilder.__log_start("Bundling Image")
    if self.options.product_family == "bruno":
      binaries_dir = os.path.abspath(self.options.base_dir+"/images")
      staging_dir = os.path.abspath(self.options.base_dir+"/staging")
      host_dir = os.path.abspath(self.options.base_dir+"/host")
      opt_file = open(staging_dir+"/etc/kernel_ubi_opts")
      ubi_ubinize_opts = ' '.join(opt_file.read().strip().split())
      opt_file.close()
      # gzip vmlinux
      Logger.info("Creating vmlinuz...")
      vmlinux_path=binaries_dir+"/vmlinux"
      if self.options.initramfs:
        vmlinux_path += "-initramfs"
      if not os.path.exists(vmlinux_path):
        raise BuildError("Cannot find " + vmlinux_path);
      vmlinux = open(vmlinux_path, "rb")
      vmlinuz = gzip.open(binaries_dir+"/vmlinuz", "wb", 9)
      vmlinuz.write(vmlinux.read())
      vmlinuz.close()
      vmlinux.close()
      # ubinize vmlinz
      Logger.info("Creating ubi image for vmlinuz...")
      cmd = host_dir + "/usr/sbin/ubinize -o " + binaries_dir + \
            "/vmlinuz.ubi " + ubi_ubinize_opts + ' ' + staging_dir + \
            "/etc/kernel_ubinize.cfg"
      p = subprocess.Popen(cmd, cwd=binaries_dir, shell=True)
      p.communicate()
      if p.returncode != 0:
        raise BuildError("Failed to execute [" + cmd +"]")
      # bundle image in hdf format
      Logger.info("Creating final hdf image...")
      shutil.copyfile(staging_dir+"/usr/lib/humax/loader.bin",
                      binaries_dir+"/loader.bin")
      cmd = [staging_dir+"/usr/lib/humax/makehdf",
             staging_dir+"/usr/lib/bruno/lkr.cfg", "bruno.hdf"]
      p = subprocess.Popen(cmd, cwd=binaries_dir)
      p.communicate()
      if p.returncode != 0:
        raise BuildError("Failed to execute [" + ' '.join(cmd) +"]")
      # bundle image in tar format
      Logger.info("Creating final tgz image...")
      tar = tarfile.open(binaries_dir+"/bruno_ginstall_image.tgz", "w:gz")
      tar.add(binaries_dir+"/vmlinuz", "vmlinuz");
      tar.add(binaries_dir+"/rootfs.squashfs_ubi",
              "rootfs.squashfs_ubi");
      tar.close()
    BuildRootBuilder.__log_done("Bundling Image")
    return

def main():
  parser = OptionParser(usage="usage: %prog [options] build-directory",
                        version="%prog 1.0")
  parser.add_option("-p", "--product-family",
                    dest="product_family",
                    default="bruno",
                    help="Product Family (e.g bruno, bcm7425), DEFAULT=bruno.")
  parser.add_option("-m", "--model",
                    dest="model",
                    default="gfhd100",
                    help="Model Name (e.g gfhd100). DFFAULT=gfhd100")
  parser.add_option("-c", "--chip-revision",
                    dest="chip_revision",
                    default="b0",
                    help="Chip Revision (e.g a0, a1, b0, b1, b2). DFFAULT=b0")
  parser.add_option("-v", "--verbose",
                    action="store_true",
                    dest="verbose",
                    default=False,
                    help="Enable the verbose mode. DEFAULT=False")
  parser.add_option("-n", "--no-initramfs",
                    action="store_false",
                    dest="initramfs",
                    default=True,
                    help="Build kernel without initramfs. DEFAULT=False")
  parser.add_option("-d", "--debug-image",
                    action="store_true",
                    dest="debug",
                    default=False,
                    help="Build debug image with extra capabilities included in"
                    + "the image, e.g. no -g, no test packages. DEFAULT=False")
  parser.add_option("-b", "--bundle-only",
                    action="store_true",
                    dest="bundle_only",
                    default=False,
                    help="Only bundle the image. DEFAULT=False")
  (options, remainder) = parser.parse_args()
  if len(remainder) != 1:
    parser.error("Incorrect arguments - " + ' '.join(remainder))
  options.base_dir = os.path.abspath(remainder[0]);
  if (not os.path.exists(options.base_dir)):
    Logger.warn("Build directory " + options.base_dir + \
                " does not exist, creating it...")
    os.makedirs(options.base_dir)
  options.top_dir = os.path.abspath(os.path.dirname(sys.argv[0]) + "/..");
  builder = BuildRootBuilder(options)
  builder.build()

if __name__ == "__main__":
    main()