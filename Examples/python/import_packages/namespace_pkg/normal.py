import os
import subprocess
import sys

print(" Starting subtest " + os.path.basename(__file__))

# Package brave found under one path
sys.path.insert(0, 'path1')

from brave import robin
print("  Finished from brave import robin")

if not(robin.run() == "AWAY!"):
    raise RuntimeError("test failed")

commandline = sys.executable + " -m brave.robin"
subprocess.check_call(commandline, shell=True, env = {"PYTHONPATH": "path1"})
print("  Finished running: " + commandline)
