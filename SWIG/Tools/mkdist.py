#!/usr/local/bin/python

# This script builds a SWIG1.3 distribution.
# Usage : mkdist.py dirname 

import sys

try:
   dirname = sys.argv[1]
except:
   print "Usage: mkdist.py directory"
   sys.exit(0)

# If directory exists, remove it
import os
print "Removing ", dirname
os.system("rm -rf "+dirname)

# Do a CVS export on the directory name

print "Checking out SWIG"
os.system("cvs export -D now -d "+dirname+ " SWIG")

# Now clean the source directory

SOURCES = ['DOH','Swig','Preprocessor','SWIG1.1','Modules1.1', 'Include']

srcs = [ ]
for d in SOURCES:
	srcs.append(dirname+"/Source/"+d)

print "Cleaning the source directory..."
import glob
import string
dirs = glob.glob(dirname+"/Source/*")
dnames = [ ]
for d in dirs:
      if not (d in srcs):
		print "Removing ", d
		os.system("rm -rf "+d)
		dnames.append(string.split(d,"/")[-1])

print "Patching the configure script"

f = open(dirname+"/configure.in")
s = f.read()
f.close()

# Remove any dirs not in SOURCES from the configure line

print dnames

for d in dnames:
	s = string.replace(s,"Source/"+d+"/Makefile","")
	s = string.replace(s,"Source/"+d,"")
	
f = open(dirname+"/configure.in","w")
f.write(s)
f.close()

# Clean the documentation directory

print "Cleaning the Doc directory"
os.system("rm -rf "+dirname+"/Doc/*")

# Blow away all .cvsignore files

print "Blowing away .cvsignore files"
os.system("find "+dirname+" -name .cvsignore -exec rm {} \\;");

# Go build the system

os.system("cd "+dirname+"; autoconf")
os.system("cd "+dirname+"/Source/DOH; autoconf")
os.system("cd "+dirname+"/Tools; autoconf")
os.system("cd "+dirname+"/Source/SWIG1.1; bison -y -d parser.yxx; mv y.tab.c parser.cxx; mv y.tab.h parser.h")

os.system("tar -cf "+string.lower(dirname)+".tar "+dirname)
os.system("gzip "+string.lower(dirname)+".tar")

