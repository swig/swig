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
print("Testing " + testname + " - %module(package=...) + python 'import' in __init__.py")

import py3.pkg2
print("  Finished importing py3.pkg2")
# commandline = sys.executable + " -m py3.pkg2.bar"
# run_except_on_windows(commandline)
# commandline = sys.executable + " -m py3.pkg2.foo"
# run_except_on_windows(commandline)

# TODO: Commented out code above results in (from python-3.6 onwards):
# RuntimeWarning: 'py3.pkg2.bar' found in sys.modules after import of package 'py3.pkg2', but prior to execution of 'py3.pkg2.bar'; this may result in unpredictable behaviour
