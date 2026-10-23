from python_typemap_numoutputs import *
from swig_test_utils import *

# An out typemap with numoutputs=0 does not contribute a returned value, so only the
# argout values are returned and a single argout value is not wrapped in a list.
swig_check(suppressed_two(0), [11, 12])
swig_check(suppressed_one(0), 11)
swig_check(suppressed_none(0), None)

with swig_assert_raises(RuntimeError):
    suppressed_two(1)
with swig_assert_raises(RuntimeError):
    suppressed_none(1)

# A user defined out typemap for void does not stop the return being void, so a single argout
# value is returned on its own rather than appended to the None the out typemap sets.
swig_check(user_void_out(), 11)
swig_check(user_void_out_two(), [11, 12])
