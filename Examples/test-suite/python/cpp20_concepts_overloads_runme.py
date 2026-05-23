from cpp20_concepts_overloads import *

from swig_test_utils import swig_check

# Function template overload by arity, each branch carrying the same requires-clause.  All three arities dispatch correctly.
swig_check(accumulate_int(5),       6)
swig_check(accumulate_int(5, 3),    8)
swig_check(accumulate_int(1, 2, 3), 6)

swig_check(accumulate_double(2.5),           3.5)
swig_check(accumulate_double(1.5, 2.5),      4.0)
swig_check(accumulate_double(0.5, 1.0, 2.5), 4.0)

# Member operator overloads with trailing requires-clauses.
a = BoxInt(7)
b = BoxInt(7)
c = BoxInt(9)
swig_check(a.eq(b),      True)
swig_check(a.eq(c),      False)
swig_check(a.plus(c).v,  16)

ad = BoxDouble(1.5)
bd = BoxDouble(1.5)
cd = BoxDouble(2.5)
swig_check(ad.eq(bd),     True)
swig_check(ad.eq(cd),     False)
swig_check(ad.plus(cd).v, 4.0)
