#!/usr/bin/env python

# This script builds the SWIG source tarball, creates the Windows executable and the Windows zip package
# and uploads them both to SF ready for release. Also uploaded are the release notes.
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
   print "where version should be x.y.z and username is your SF username"
   sys.exit(1)

print "Looking for rsync"
os.system("which rsync") and failed("rsync not installed/found. Please install.")

print "Making source tarball"
os.system("python ./mkdist.py " + version) and failed("")

print "Build Windows package"
os.system("./mkwindows.sh " + version) and failed("")

print "Uploading to SourceForge"

swig_dir_sf = username + ",swig@frs.sourceforge.net:/home/frs/project/s/sw/swig/swig/swig-" + version + "/"
swigwin_dir_sf = username + ",swig@frs.sourceforge.net:/home/frs/project/s/sw/swig/swigwin/swigwin-" + version + "/"

release_notes_file = "release-notes-" + version + ".txt"
os.system("rm -f " + release_notes_file)
os.system("cat swig-" + version + "/README " + "swig-" + version + "/CHANGES.current > " + release_notes_file)

os.system("rsync --archive --verbose -P --times -e ssh " + "swig-" + version + ".tar.gz " + release_notes_file + " " + swig_dir_sf) and failed("")
os.system("rsync --archive --verbose -P --times -e ssh " + "swigwin-" + version + ".zip " + swigwin_dir_sf) and failed("")

os.system("svn copy -m \"rel-" + version + "\" https://swig.svn.sourceforge.net/svnroot/swig/trunk https://swig.svn.sourceforge.net/svnroot/swig/tags/rel-" + version + "/")

print "Finished"

print "Now log in to SourceForge and set the operating system and link the release notes to each of the tarball and zip file in the File Manager."
