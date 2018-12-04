import os
import subprocess
import sys

print(" Starting subtest " + os.path.basename(__file__))

# Package brave split into two paths.
# brave/robin.py (in path4.zip) and path3/brave/_robin.so
sys.path.insert(0, 'path4.zip')
sys.path.insert(0, 'path3')

from brave import robin
print("  Finished from brave import robin")

if not(robin.run() == "AWAY!"):
    raise RuntimeError("test failed")

commandline = sys.executable + " -m brave.robin"
subprocess.check_call(commandline, shell=True, env = {"PYTHONPATH": "path3:path4.zip"})
print("  Finished running: " + commandline)
