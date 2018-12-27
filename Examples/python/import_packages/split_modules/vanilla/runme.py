import os.path
import subprocess
import sys

def run_except_on_windows(commandline, env=None):
    if os.name != "nt" and sys.platform != "cygwin":
        # Strange failures on windows/cygin/mingw
        subprocess.check_call(commandline, env=env, shell=True)
        print("  Finished running: " + commandline)

testname = os.path.basename(os.path.dirname(os.path.abspath(__file__)))
print "Testing " + testname + " - split modules"

import pkg1.foo

print "  Finished importing pkg1.foo"

if not(pkg1.foo.count() == 3):
    raise RuntimeError("test failed")

commandline = sys.executable + " -m pkg1.foo"
run_except_on_windows(commandline)
