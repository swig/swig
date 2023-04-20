import os.path
import subprocess
import sys

def run_except_on_windows(commandline, env=None):
    if os.name != "nt" and sys.platform != "cygwin":
        # Strange failures on windows/cygwin/mingw
        subprocess.check_call(commandline, env=env, shell=True)
        print(("  Finished running: " + commandline))

# Test import of same modules from different packages
testname = os.path.basename(os.path.dirname(os.path.abspath(__file__)))
print("Testing " + testname + " - %module(package=...) + python 'import' in __init__.py")

import pkg2.foo
print("  Finished importing pkg2.foo")

var2 = pkg2.foo.Pkg2_Foo()

classname = str(type(var2))
if classname.find("pkg2.foo.Pkg2_Foo") == -1:
    raise RuntimeError("failed type checking: " + classname)
print("  Successfully created object pkg2.foo.Pkg2_Foo")

commandline = sys.executable + " -m pkg2.foo"
run_except_on_windows(commandline)
