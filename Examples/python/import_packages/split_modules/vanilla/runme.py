import os.path

testname = os.path.basename(os.path.dirname(os.path.abspath(__file__)))
print "Testing " + testname + " - split modules"

import pkg1.foo

print "  Finished importing pkg1.foo"

if not(pkg1.foo.count() == 3):
    raise RuntimeError("test failed")
