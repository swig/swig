# This is the import runtime testcase.

import imports_a
import imports_b
import sys

x = imports_b.B()
imports_a.A.hello(x)

