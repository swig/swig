#!/usr/bin/env python

import sys
import os
import subprocess

def failed():
    print("mkdist.py failed to complete")
    sys.exit(2)

import argparse
parser = argparse.ArgumentParser(description="Build a SWIG distribution tarball swig-x.y.z.tar.gz")
parser.add_argument("version", help="version string in format x.y.z")
parser.add_argument("-b", "--branch", required=False, default="master", help="git branch name to create tarball from [master]")
parser.add_argument("-f", "--force-tag", required=False, action="store_true", help="force tag (replace git tag if it already exists)")
parser.add_argument("-s", "--skip-checks", required=False, action="store_true", help="skip checks (that local and remote repos are in sync)")
args = parser.parse_args()

version = args.version
branch = args.branch
dirname = "swig-" + version
force_tag = args.force_tag
skip_checks = args.skip_checks

if sys.version_info[0:2] < (2, 7):
     print("Error: Python 2.7 or higher is required")
     sys.exit(3)

# Check name matches normal unix conventions
if dirname.lower() != dirname:
    print("directory name (" + dirname + ") should be in lowercase")
    sys.exit(3)

# If directory and tarball exist, remove it
print("Removing " + dirname)
os.system("rm -rf " + dirname)

print("Removing " + dirname + ".tar if exists")
os.system("rm -f " + dirname + ".tar.gz")

print("Removing " + dirname + ".tar.gz if exists")
os.system("rm -f " + dirname + ".tar")

# Grab the code from git

print("Checking there are no local changes in git repo")
os.system("git remote update origin") == 0 or failed()
command = ["git", "status", "--porcelain", "-uno"]
out = subprocess.check_output(command)
if out.strip() != "":
    print("Local git repository has modifications")
    print(" ".join(command))
    print(out)
    sys.exit(3)

if not skip_checks:
    print("Checking git repository is in sync with remote repository")
    command = ["git", "log", "--oneline", branch + "..origin/" + branch]
    out = subprocess.check_output(command)
    if out.strip() != "":
        print("Remote repository has additional modifications to local repository")
        print(" ".join(command))
        print(out)
        sys.exit(3)

    command = ["git", "log", "--oneline", "origin/" + branch + ".." + branch]
    out = subprocess.check_output(command)
    if out.strip() != "":
        print("Local repository has modifications not pushed to the remote repository")
        print("These should be pushed and checked that they pass Continuous Integration testing before continuing")
        print(" ".join(command))
        print(out)
        sys.exit(3)

print("Tagging release")
tag = "'rel-" + version + "'"
force = "-f " if force_tag else ""
os.system("git tag -a -m " + tag + " " + force + tag) == 0 or failed()

outdir = os.path.basename(os.getcwd()) + "/" + dirname + "/"
print("Grabbing tagged release git repository using 'git archive' into " + outdir)
os.system("(cd .. && git archive --prefix=" + outdir + " " + tag + " . | tar -xf -)") == 0 or failed()

# Go build the system

print("Building system")
os.system("cd " + dirname + " && ./autogen.sh") == 0 or failed()
os.system("cd " + dirname + "/Source/CParse && bison -y -d parser.y && mv y.tab.c parser.c && mv y.tab.h parser.h") == 0 or failed()
os.system("cd " + dirname + " && make -f Makefile.in libfiles srcdir=./") == 0 or failed()

# Remove autoconf files
os.system("find " + dirname + " -name autom4te.cache -exec rm -rf {} \\;")

# Build documentation
print("Building html documentation")
os.system("cd " + dirname + "/Doc/Manual && make all clean-baks") == 0 or failed()

# Build the tar-ball
os.system("tar -cf " + dirname + ".tar " + dirname) == 0 or failed()
os.system("gzip " + dirname + ".tar") == 0 or failed()

print("Finished building " + dirname + ".tar.gz")

