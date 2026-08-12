from c_this_identifier import *
from swig_test_utils import swig_check

swig_check(this_plus_one(1), 2)
swig_check(this_local(), 42)

swig_check(cvar.this_global, 40)
cvar.this_global = 7
swig_check(cvar.this_global, 7)

q = Q()
q.this_value = 7
swig_check(q.this_value, 7)
