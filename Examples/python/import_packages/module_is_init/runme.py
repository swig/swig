import os.path
import sys

# Test import of a SWIG generated module renamed as the package's __init__.py
testname = os.path.basename(os.path.dirname(os.path.abspath(__file__)))
print("Testing " + testname + " - module renamed as __init__.py")

import pkg1
print("  Finished importing pkg1")

if pkg1.foofunction(123) != 1230:
    raise RuntimeError("foofunction failed")

fc = pkg1.FooClass()
if fc.foomethod(1) != 6:
    raise RuntimeError("foomethod failed")

print("  Finished testing pkg1")
