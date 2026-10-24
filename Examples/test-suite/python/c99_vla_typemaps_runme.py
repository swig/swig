from c99_vla_typemaps import *
from swig_test_utils import swig_check

# Multi-argument typemaps
multi_star(2, None)
swig_check(seen_size(0), 2)
multi_named(3, None)
swig_check(seen_size(0), 3)
multi_plain(4, None)
swig_check(seen_size(0), -1)
multi_pair(5, None, None)
swig_check(seen_size(0), 5)
swig_check(seen_size(1), 5)

# Multidimensional arrays
grid(2, 3, None)
swig_check([seen_size(0), seen_size(1), seen_size(2)], [2, 3, 6])
three_rows(5, None)
swig_check([seen_size(0), seen_size(1), seen_size(2)], [3, 5, 15])
four_columns(2, None)
swig_check([seen_size(0), seen_size(1), seen_size(2)], [2, 4, 8])

# %apply and %clear
applied(6, None)
swig_check(seen_size(0), 6)
cleared(7, None)
swig_check(seen_size(0), -1)

# A typemap written with '[*]' comes before one for an array of unknown size
const_ints(8, None)
swig_check(seen_size(0), 8)
my_shorts(9, None)
swig_check(seen_size(0), 9)
points(10, None)
swig_check(seen_size(0), 10)

# Type variables
floats(11, None)
swig_check(seen_type(), "float [] float (*)[]")

# Sizes that are structure members
d = Dims()
d.rows = 2
d.cols = 3
member_sizes(d, None)
swig_check(seen_size(0), 23)

# Typedefs
typedef_longs(4, None)
swig_check(seen_size(0), 4)
typedef_rows(5, None)
swig_check([seen_size(0), seen_size(1), seen_size(2)], [5, 3, 15])

# Ignored arguments at the start, in the middle and at the end
swig_check(ignored_arguments(3, 10), 133)
swig_check(ignored_arguments(0, 10), 100)
