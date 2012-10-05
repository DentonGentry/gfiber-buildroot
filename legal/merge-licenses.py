#!/usr/bin/python
"""Merge the licenses in licenses/.../* into a single file on stdout.

The file should be suitable for including in a UI as the list of all
licenses used in the system.
"""

import hashlib
import os
import os.path
import re


def WalkDir(path):
  """Like os.path.walk() but doesn't need you to define a callback."""
  out = []

  def Func(_, dirname, fnames):
    for fname in fnames:
      fullname = os.path.join(dirname, fname)
      if os.path.isfile(fullname):
        out.append(fullname[len(path)+1:])

  os.path.walk(path, Func, None)
  return out


def NameSort(name):
  leading = int(re.match(r'\d*', name).group(0) or 9999)
  return leading, name


def NameListSort(names):
  return list(sorted(names, key=NameSort))


preamble = open('preamble.txt').read()
hash2content = {}
hash2names = {}

os.chdir('licenses')

for name in WalkDir('.'):
  if name.endswith('~'): continue
  if '/' not in name: continue
  content = open(name).read()
  fix = re.sub(r'\s+', '', content)
  sha1 = hashlib.sha1(fix).hexdigest()
  hash2content[sha1] = content
  if not sha1 in hash2names:
    hash2names[sha1] = []
  hash2names[sha1].append(name)

print preamble
for sha1, names in sorted(hash2names.iteritems(),
                          key=lambda i: NameListSort(i[1])):
  content = hash2content[sha1]
  content = re.sub(re.compile(r'[ \t\r\x0c]+$', re.M), '', content)
  if not content: continue
  print
  print
  print '------------------------------------------------'
  for name in sorted(names):
    print name
  print '------------------------------------------------'
  print content
