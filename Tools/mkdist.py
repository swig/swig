#!/usr/local/bin/python

# This script builds a swig-1.3 distribution.
# Usage : mkdist.py version, where version should be 1.3.x

import sys
import string
import os

try:
   version = sys.argv[1]
   dirname = "swig-" + version
except:
   print "Usage: mkdist.py version, where version should be 1.3.x"
   sys.exit(0)

# Check name matches normal unix conventions
if string.lower(dirname) != dirname:
  print "directory name ("+dirname+") should be in lowercase"
  sys.exit(0)

# If directory and tarball exist, remove it
print "Removing ", dirname
os.system("rm -rf "+dirname)

print "Removing "+dirname+".tar if exists"
os.system("rm -f "+dirname+".tar.gz")

print "Removing "+dirname+".tar.gz if exists"
os.system("rm -f "+dirname+".tar")

# Do a SVN export into the directory name

print "Grabbing latest SWIG from svn"
os.system("svn export -r HEAD https://swig.svn.sourceforge.net/svnroot/swig/trunk "+dirname)

# Remove the debian directory -- it's not official

os.system("rm -Rf "+dirname+"/debian");

# Blow away all .cvsignore files

print "Blowing away .cvsignore files"
os.system("find "+dirname+" -name .cvsignore -exec rm {} \\;");

# Go build the system

print "Building system"
os.system("cd "+dirname+"; ./autogen.sh")
os.system("cd "+dirname+"/Tools/WAD; autoconf")
os.system("cd "+dirname+"; make maintainer")

# Remove autoconf files
os.system("find "+dirname+" -name autom4te.cache -exec rm -rf {} \\;");

# Build documentation
print "Building documentation"
os.system("cd "+dirname+"/Doc/Manual; make; rm *.bak")

# Build the tar-ball
os.system("tar -cf "+dirname+".tar "+dirname)
os.system("gzip "+dirname+".tar")

