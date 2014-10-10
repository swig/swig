import os.path

# Test import of same modules from different packages
testname = os.path.basename(os.path.dirname(os.path.abspath(__file__)))
print "Testing " + testname + " - %module(package=...) + python 'import' in __init__.py"

import pkg2.foo
print "  Finished importing pkg2.foo"

var2 = pkg2.foo.Pkg2_Foo()
if str(type(var2)).find("'pkg2.foo.Pkg2_Foo'") == -1:
  raise RuntimeError("failed type checking: " + str(type(var2)))
print "  Successfully created object pkg2.foo.Pkg2_Foo"
