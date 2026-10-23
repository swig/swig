import os.path
import subprocess
import sys

def run_except_on_windows(commandline, env=None):
    if os.name != "nt" and sys.platform != "cygwin":
        # Strange failures on windows/cygwin/mingw
        subprocess.check_call(commandline, env=env, shell=True)
        print(("  Finished running: " + commandline))

# Test import of modules content from within __init__.py
testname = os.path.basename(os.path.dirname(os.path.abspath(__file__)))
print("Testing " + testname + " - %module(package=...) with -relativeimport")

import py3.pkg2.bar
print("  Finished importing py3.pkg2.bar")
commandline = sys.executable + " -m py3.pkg2.bar"
run_except_on_windows(commandline)
commandline = sys.executable + " -m py3.pkg2.pkg3.foo"
run_except_on_windows(commandline)
