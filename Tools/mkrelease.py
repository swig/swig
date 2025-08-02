#!/usr/bin/env python3

import sys
import os
from utils import *

def failed(message):
  if message == "":
    print("mkrelease.py failed to complete")
  else:
    print(message)
  sys.exit(2)

import argparse
parser = argparse.ArgumentParser(description="Build a SWIG distribution source tarball swig-x.y.z.tar.gz and the Windows zip package swigwin-x.y.z.zip.\nUpload them both to SourceForge ready for release.\nThe release notes are also uploaded.")
parser.add_argument("version", help="version string in format x.y.z")
parser.add_argument("-b", "--branch", required=False, default="master", help="git branch name to create tarball from [master]")
parser.add_argument("-f", "--force-tag", required=False, action="store_true", help="force tag (replace git tag if it already exists)")
parser.add_argument("-s", "--skip-checks", required=False, action="store_true", help="skip checks (that local and remote repos are in sync)")
parser.add_argument("-u", "--username", required=False, help="SourceForge username (upload to SourceForge will be skipped if not provided)")
args = parser.parse_args()

version = args.version
branch = args.branch
dirname = "swig-" + version
force_tag = args.force_tag
skip_checks = args.skip_checks
username = args.username

print("Looking for rsync")
run_command("which", "rsync") and failed("rsync not installed/found. Please install.")

print("Making source tarball")
force = "--force-tag" if force_tag else ""
skip = "--skip-checks" if skip_checks else ""
toolsdir = os.path.dirname(os.path.abspath(__file__))
cmd = "{} {}/mkdist.py {} {} --branch {} {}".format(sys.executable, toolsdir, force, skip, branch, version).split()
run_command(*cmd) and failed("")

print("Build Windows package")
run_command("{}/mkwindows.sh".format(toolsdir), version) and failed("")

if username:
    print("Uploading to SourceForge")

    swig_dir_sf = username + ",swig@frs.sourceforge.net:/home/frs/project/s/sw/swig/swig/swig-" + version + "/"
    swigwin_dir_sf = username + ",swig@frs.sourceforge.net:/home/frs/project/s/sw/swig/swigwin/swigwin-" + version + "/"

    # If a file with 'readme' in the name exists in the same folder as the zip/tarball, it gets automatically displayed as the release notes by SF
    full_readme_file = "readme-" + version + ".txt"
    run_command("rm", "-f", full_readme_file)
    run_command("cat", "swig-" + version + "/README", "swig-" + version + "/CHANGES.current", "swig-" + version + "/RELEASENOTES", ">", full_readme_file)

    run_command("rsync", "--archive", "--verbose", "-P", "--times", "-e", "ssh", "swig-" + version + ".tar.gz", full_readme_file, swig_dir_sf) and failed("")
    run_command("rsync", "--archive", "--verbose", "-P", "--times", "-e", "ssh", "swigwin-" + version + ".zip", full_readme_file, swigwin_dir_sf) and failed("")

    print("Finished")

    print("Now log in to SourceForge and set the operating systems applicable to the newly uploaded tarball and zip file. Also remember to do a 'git push --tags'.")
