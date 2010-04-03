#!/usr/bin/env python

# This script builds a swig-x.y.z distribution.
# Usage : mkdist.py version, where version should be x.y.z

import sys
import string
import os

def failed():
  print "mkdist.py failed to complete"
  sys.exit(2)


try:
   version = sys.argv[1]
   dirname = "swig-" + version
except:
   print "Usage: mkdist.py version, where version should be x.y.z"
   sys.exit(1)

# Check name matches normal unix conventions
if string.lower(dirname) != dirname:
  print "directory name ("+dirname+") should be in lowercase"
  sys.exit(3)

# If directory and tarball exist, remove it
print "Removing ", dirname
os.system("rm -rf "+dirname)

print "Removing "+dirname+".tar if exists"
os.system("rm -f "+dirname+".tar.gz")

print "Removing "+dirname+".tar.gz if exists"
os.system("rm -f "+dirname+".tar")

# Do a SVN export into the directory name

print "Grabbing latest SWIG from svn"
os.system("svn export -r HEAD https://swig.svn.sourceforge.net/svnroot/swig/trunk "+dirname) == 0 or failed()

# Remove the debian directory -- it's not official

os.system("rm -Rf "+dirname+"/debian") == 0 or failed()

# Go build the system

print "Building system"
os.system("cd "+dirname+" && ./autogen.sh") == 0 or failed()
os.system("cd "+dirname+"/Tools/WAD && autoconf") == 0 or failed()
os.system("cd "+dirname+"/Source/CParse && bison -y -d parser.y && mv y.tab.c parser.c && mv y.tab.h parser.h") == 0 or failed()
os.system("cd "+dirname+" && make -f Makefile.in libfiles srcdir=./") == 0 or failed()

# Remove autoconf files
os.system("find "+dirname+" -name autom4te.cache -exec rm -rf {} \\;")

# Build documentation
print "Building html documentation"
os.system("cd "+dirname+"/Doc/Manual && make all clean-baks") == 0 or failed()
print "Building man pages"
os.system("cd "+dirname+"/CCache && yodl2man -o ccache-swig.1 ccache.yo") == 0 or failed()

# Build the tar-ball
os.system("tar -cf "+dirname+".tar "+dirname) == 0 or failed()
os.system("gzip "+dirname+".tar") == 0 or failed()

