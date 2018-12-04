import os
import subprocess
import sys

print(" Starting subtest " + os.path.basename(__file__))

# Package brave split into two paths.
# path2/brave/robin.py and path3/brave/_robin.so
sys.path.insert(0, 'path2')
sys.path.insert(0, 'path3')

from brave import robin
print("  Finished from brave import robin")

if not(robin.run() == "AWAY!"):
    raise RuntimeError("test failed")

commandline = sys.executable + " -m brave.robin"
subprocess.check_call(commandline, shell=True, env = {"PYTHONPATH": "path2:path3"})
print("  Finished running: " + commandline)
