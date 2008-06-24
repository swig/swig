#!/usr/bin/python

# This script builds the SWIG source tarball, creates the Windows executable and the Windows zip package
# and uploads them both to SF ready for release
import sys
import string
import os

def failed(message):
  if message == "":
    print "mkrelease.py failed to complete"
  else:
    print message
  sys.exit(2)

try:
   version = sys.argv[1]
   username = sys.argv[2]
except:
   print "Usage: python mkrelease.py version username"
   print "where version should be 1.3.x and username is your SF username"
   sys.exit(1)

print "Looking for rsync"
os.system("which rsync") and failed("rsync not installed/found. Please install.")

print "Making source tarball"
os.system("python ./mkdist.py " + version) and failed("")

print "Build Windows package"
os.system("./mkwindows.sh " + version) and failed("")

print "Uploading to Sourceforge"
os.system("rsync --archive --verbose -P --times -e ssh swig-" + version + ".tar.gz " + username + "@frs.sourceforge.net:uploads/") and failed("")
os.system("rsync --archive --verbose -P --times -e ssh swigwin-" + version + ".zip " + username + "@frs.sourceforge.net:uploads/") and failed("")

os.system("svn copy -m \"rel-" + version + "\" https://swig.svn.sourceforge.net/svnroot/swig/trunk https://swig.svn.sourceforge.net/svnroot/swig/tags/rel-" + version + "/")

print "Finished"
