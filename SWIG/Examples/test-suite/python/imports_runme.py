# This is the import runtime testcase.

import _imports_a
import _imports_b
import sys

x = _imports_b.new_B()
_imports_a.A_hello(x)

