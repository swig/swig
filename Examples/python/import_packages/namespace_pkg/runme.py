import os, sys, setupPkg

# These examples rely on namespace packages.  Don't
# run them for old python interpreters.
if sys.version_info < (3, 3, 0):
    sys.exit(0)

setupPkg.copyMods()

# Run each test with a seperate interpreter
os.system(sys.executable + " nonpkg.py")
os.system(sys.executable + " normal.py")
os.system(sys.executable + " split.py")
os.system(sys.executable + " zipsplit.py")
