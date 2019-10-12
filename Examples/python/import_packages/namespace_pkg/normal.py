import os
import subprocess
import sys

def run_except_on_windows(commandline, env=None):
    if os.name != "nt" and sys.platform != "cygwin":
        # Strange failures on windows/cygin/mingw
        subprocess.check_call(commandline, env=env, shell=True)
        print("  Finished running: " + commandline)

print(" Starting subtest " + os.path.basename(__file__))

# Package brave found under one path
sys.path.insert(0, "path1")

from brave import robin
print("  Finished from brave import robin")

if not(robin.run() == "AWAY!"):
    raise RuntimeError("test failed")

commandline = sys.executable + " -m brave.robin"
run_except_on_windows(commandline, env = {"PYTHONPATH": "path1"})
