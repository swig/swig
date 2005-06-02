#!/usr/local/bin/python

# This script builds a swig-1.3 distribution.
# Usage : mkdist.py directory, where directory should be swig-1.3.x

import sys
import string
import os

try:
   dirname = sys.argv[1]
except:
   print "Usage: mkdist.py directory, where directory should be swig-1.3.x"
   sys.exit(0)

# Check name matches normal unix conventions
if string.lower(dirname) != dirname:
  print "directory name ("+dirname+") should be in lowercase"
  sys.exit(0)

# If directory exists, remove it
print "Removing ", dirname
os.system("rm -rf "+dirname)

# Do a CVS export on the directory name

print "Checking out SWIG"
os.system("cvs export -D now -d "+dirname+ " SWIG")

# Remove the debian directory -- it's not official

os.system("rm -Rf "+dirname+"/debian");

# Blow away all .cvsignore files

print "Blowing away .cvsignore files"
os.system("find "+dirname+" -name .cvsignore -exec rm {} \\;");

# Go build the system

print "Building system"
os.system("cd "+dirname+"; ./autogen.sh")
os.system("cd "+dirname+"/Tools/WAD; autoconf")
os.system("cd "+dirname+"/Source/CParse; bison -y -d parser.y; mv y.tab.c parser.c; mv y.tab.h parser.h")

# Remove autoconf files
os.system("find "+dirname+" -name autom4te.cache -exec rm -rf {} \\;");

# Build documentation
print "Building documentation"
os.system("cd "+dirname+"/Doc/Manual; make; rm *.bak")

# Build the tar-ball
os.system("tar -cf "+dirname+".tar "+dirname)
os.system("gzip "+dirname+".tar")

