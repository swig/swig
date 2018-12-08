import os.path
import sys

# Test import of a SWIG generated module renamed as the package's __init__.py
testname = os.path.basename(os.path.dirname(os.path.abspath(__file__)))
print "Testing " + testname + " - module renamed as __init__.py"

if sys.version_info >= (3, 0, 0) and sys.version_info < (3, 3, 0):
    print "  Not importing as Python version is >= 3.0 and < 3.3"
    # Package detection does not work in these versions.
    # Can be fixed by using this in the interface file:
    #   %module(moduleimport="from . import $module") foo   # without -builtin
    #   %module(moduleimport="from .$module import *") foo  # with -builtin
    sys.exit(0)

import pkg1
print "  Finished importing pkg1"

if pkg1.foofunction(123) != 1230:
    raise RuntimeError("foofunction failed")

fc = pkg1.FooClass()
if fc.foomethod(1) != 6:
    raise RuntimeError("foomethod failed")

print "  Finished testing pkg1"
