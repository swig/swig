import os
import subprocess
import sys

print(" Starting subtest " + os.path.basename(__file__))

# import robin as a module in the global namespace

import robin
print("  Finished importing robin")

if not(robin.run() == "AWAY!"):
    raise RuntimeError("test failed")

commandline = sys.executable + " -m robin"
subprocess.check_call(commandline, shell=True)
print("  Finished running: " + commandline)
