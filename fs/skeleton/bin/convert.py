#!/usr/bin/python
# Copyright 2013 Google Inc. All Rights Reserved.

"""To lowercase"""

__author__ = 'zixia@google.com (Ted Huang)'

import sys

def usage(cmdname):
  print 'Usage: python ' + cmdname + ' lower/upper string'

def main():
  if len(sys.argv) < 3:
    usage(sys.argv[0])
  else:
    if sys.argv[1] == 'lower':
      print sys.argv[2].lower()
    elif sys.argv[1] == 'upper':
      print sys.argv[2].upper()
    else:
      usage(sys.argv[0])

if __name__ == '__main__':
  main()
