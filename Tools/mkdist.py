#!/usr/bin/env python3

import sys
import os
import subprocess
from utils import *

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

# Tools directory path $ENV/swig/Tools
toolsdir = os.path.dirname(os.path.abspath(__file__))
# Root directory path (swig) $ENV/swig
rootdir = os.path.abspath(os.path.join(toolsdir, os.pardir))
# current directory
current_dir = os.getcwd()
# version directory path $ENV/swig/<x.x.x>
dirpath = os.path.join(current_dir, dirname)

if sys.version_info[0:2] < (2, 7):
     print("Error: Python 2.7 or higher is required")
     sys.exit(3)

# Check name matches normal unix conventions
if dirname.lower() != dirname:
    print("directory name (" + dirname + ") should be in lowercase")
    sys.exit(3)

# If directory and tarball exist, remove it
if check_dir_exists(dirpath):
    print("Removing " + dirpath)
    run_command("rm", "-rf", dirpath)

filename = dirpath + ".tar"
if check_file_exists(filename):
    print("Removing " + filename)
    run_command("rm", "-rf", filename)

filename += ".gz"
if check_file_exists(filename):
    print("Removing " + filename)
    run_command("rm", "-rf", filename)

# Grab the code from git

print("Checking there are no local changes in git repo")
run_command("git", "remote", "update", "origin") == 0 or failed()
command = ["git", "status", "--porcelain", "-uno"]
out = subprocess.check_output(command)
if out.strip():
    print("Local git repository has modifications")
    print(" ".join(command))
    print(out)
    sys.exit(3)

if not skip_checks:
    print("Checking git repository is in sync with remote repository")
    command = ["git", "log", "--oneline", branch + "..origin/" + branch]
    out = subprocess.check_output(command)
    if out.strip():
        print("Remote repository has additional modifications to local repository")
        print(" ".join(command))
        print(out)
        sys.exit(3)

    command = ["git", "log", "--oneline", "origin/" + branch + ".." + branch]
    out = subprocess.check_output(command)
    if out.strip():
        print("Local repository has modifications not pushed to the remote repository")
        print("These should be pushed and checked that they pass Continuous Integration testing before continuing")
        print(" ".join(command))
        print(out)
        sys.exit(3)

print("Tagging release")
tag = "v" + version
force = "-f" if force_tag else ""
command = ["git", "tag", "-a", "-m", "'Release version " + version + "'"]
force and command.append(force)
command.append(tag)
run_command(*command) == 0 or failed()

outdir = dirname + "/"
print("Grabbing tagged release git repository using 'git archive' into " + outdir)

# using pipe operator without shell=True; split commands into individual ones.
# git archive command
command = ["git", "archive", "--prefix=" + outdir, tag, "."]
archive_ps = subprocess.Popen(command, cwd=rootdir, stdout=subprocess.PIPE)
# tar -xf -
tar_ps = subprocess.Popen(("tar", "-xf", "-"), stdin=archive_ps.stdout, stdout=subprocess.PIPE)
archive_ps.stdout.close()  # Allow archive_ps to receive a SIGPIPE if tar_ps exits.
output = tar_ps.communicate()

# Go build the system

print("Building system")
run_command("mkdir", "-p", dirpath)
run_command("./autogen.sh", cwd=dirpath) == 0 or failed()

run_command("./configure", cwd=dirpath) == 0 or failed()
run_command("make", "-CSource", "CParse/parser.c", cwd=dirpath) == 0 or failed()

run_command("make", "libfiles", cwd=dirpath) == 0 or failed()

run_command("make", "distclean", cwd=dirpath) == 0 or failed()

# Remove autotools files
run_command("find", dirname, "-name", ".deps", "-exec", "rmdir", "{}", ";", cwd=rootdir)

# Build documentation
print("Building html documentation")
docpath = os.path.join(dirpath, "Doc", "Manual")
run_command("make", "all", "clean-baks", cwd=docpath) == 0 or failed()

# Build the tar-ball
run_command("tar", "-czf", dirname + ".tar.gz", dirname) == 0 or failed()

print("Finished building " + dirname + ".tar.gz")

