# These examples rely on namespace packages.  Don't
# run them for old python interpreters.
import os.path

testname = os.path.basename(os.path.dirname(os.path.abspath(__file__)))
print("Testing " + testname + " - namespace packages")

import nstest

print("  Finished importing nstest")

nstest.main()
