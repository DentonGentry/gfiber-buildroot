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
                          key=lambda i: (-len(i[1]), list(sorted(i[1])))):
  print
  print
  print '------------------------------------------------'
  for name in sorted(names):
    print name
  print '------------------------------------------------'
  print re.sub(re.compile(r'[\s\x0c]+$', re.M), '\n', hash2content[sha1])
  #print sha1
