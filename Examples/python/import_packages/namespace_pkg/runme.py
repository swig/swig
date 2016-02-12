import os, sys, setupPkg

setupPkg.copyMods()

# Run each test with a seperate interpreter
os.system(sys.executable + " nonpkg.py")
os.system(sys.executable + " normal.py")
os.system(sys.executable + " split.py")
os.system(sys.executable + " zipsplit.py")
