# These examples rely on namespace packages.  Don't
# run them for old python interpreters.
import sys
if sys.version_info < (3, 3, 0):
    sys.exit(0)

import nstest
nstest.main()
