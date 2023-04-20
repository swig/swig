import os
import subprocess
import sys

def run_except_on_windows(commandline, env=None):
    if os.name != "nt" and sys.platform != "cygwin":
        # Strange failures on windows/cygwin/mingw
        subprocess.check_call(commandline, env=env, shell=True)
        print("  Finished running: " + commandline)

print(" Starting subtest " + os.path.basename(__file__))

# import robin as a module in the global namespace

import robin
print("  Finished importing robin")

if not(robin.run() == "AWAY!"):
    raise RuntimeError("test failed")

commandline = sys.executable + " -m robin"
run_except_on_windows(commandline)
