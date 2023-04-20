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

if sys.version_info < (2, 5):
    print("  Skipping test as Python version is < 2.5 and does not support relative import syntax: 'from . import x'")
    sys.exit(0)

if sys.version_info < (3, 0):
    import py2.pkg2.bar
    print("  Finished importing py2.pkg2.bar")
    commandline = sys.executable + " -m py2.pkg2.bar"
    run_except_on_windows(commandline)
    commandline = sys.executable + " -m py2.pkg2.pkg3.pkg4.foo"
    run_except_on_windows(commandline)
else:
    import py3.pkg2.bar
    print("  Finished importing py3.pkg2.bar")
    commandline = sys.executable + " -m py3.pkg2.bar"
    run_except_on_windows(commandline)
    commandline = sys.executable + " -m py3.pkg2.pkg3.pkg4.foo"
    run_except_on_windows(commandline)
